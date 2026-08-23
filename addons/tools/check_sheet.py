# -*- coding: utf-8 -*-
r"""check_sheet.py - the UI test sheet's OFFLINE MODEL against the CLIENT's own measurement.

    py addons\tools\check_sheet.py                the summary, per font object
    py addons\tools\check_sheet.py --cells        every cell, with its residual
    py addons\tools\check_sheet.py --font X       one font object only

★★★ WHY. `addons/COA_DevDump/sheet_decl.lua` declares specimens; two renderers consume it - the
offline rect model and the client - and THIS is the diff between them. It is the loop AP-13 asks
for: the agent sees what it did, against a fact, instead of tuning success by churn.

★★ IT REPORTS DRIFT, NEVER FAILURE - `check_interface.py`'s rule, and for the same reason. A
divergence between our model of the client and the client is a FACT about two records
disagreeing. It is the output, not an alarm. Exit is non-zero only when the run cannot be
BELIEVED (no capture, dead apparatus, unreadable font), never when it merely disagrees.

★ THE FIT IS HELD OUT, AND THAT IS THE WHOLE POINT. Constants are fitted on the CALIBRATION
strings alone and the error is reported on the SPECIMEN strings, which never touched the fit.
Fitting on everything and reporting the residual would measure the fitter, not the model - and
"broad insight rather than one addon" (Battlewrath, 2026-08-23) is exactly a claim about
strings the calibration never saw.

⚠ THE MODEL IS UNHINTED. Advances come from the font's own `hmtx`, scaled linearly. The client
rasterises through FreeType and hinting moves per-glyph advances, so a residual is EXPECTED and
its size is the deliverable. What is NOT yet known is the pixel size the client rasterises at:
1/q = 1.5936 device px per returned unit, while uiScale x screenH/768 = 2.2534, so the obvious
mapping is not the right one. ⟶ One sheet run at a second uiScale separates a device-pixel
artefact from a font-engine constant. Until then every number here is conditional on ONE
configuration and the header says so.

⚠ READ-ONLY. The client archive is opened for reading; nothing is written anywhere.
"""
import argparse
import glob
import hashlib
import io
import json
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "Weak Auras"))
from lua_table import parse_file, LuaParseError  # noqa: E402  (codec-proven parser, reused not re-derived)

try:
    import mpyq
    from fontTools.ttLib import TTFont
except ImportError as e:  # pragma: no cover - environment fault, not a finding
    print(f"check_sheet: missing dependency ({e}). mpyq and fontTools are required.")
    sys.exit(2)

DECL = REPO / "addons" / "COA_DevDump" / "sheet_decl.lua"
RECORDS = REPO / "addons" / "landing" / "records"
CLIENT_DATA = Path(r"F:\games\Ascension_wow\resources\ascension-live\Data")
FONT_ARCHIVE = CLIENT_DATA / "enUS" / "locale-enUS.MPQ"

# `task_geom` cannot use "" as a table key in a readable record, so it stores the
# empty string under this name. An adapter fact about the existing capture, not a
# property of the standard.
EMPTY_KEY = "(empty)"


# --------------------------------------------------------------------------- declaration
def read_declaration():
    try:
        decl = parse_file(str(DECL)).get("COA_UI_SHEET")
    except LuaParseError as e:
        print(f"check_sheet: {DECL.name} did not parse - {e}")
        sys.exit(2)
    if not decl:
        print(f"check_sheet: {DECL.name} defines no COA_UI_SHEET")
        sys.exit(2)
    return decl


def as_list(table):
    """lua_table gives a positional table as a list; keep a dict's 1..n order too."""
    if isinstance(table, list):
        return table
    if isinstance(table, dict):
        return [table[k] for k in sorted(table, key=lambda x: int(x))]
    return []


def expand_text_cells(decl):
    """The declared cell set: every font object x every string, both roles kept."""
    text = decl.get("text") or {}
    fonts = as_list(text.get("fonts"))
    cells = []
    for role in ("calibration", "specimen"):
        for s in as_list(text.get(role)):
            for f in fonts:
                cells.append({"kind": "text", "font": f, "text": s, "role": role,
                              "id": f"text|{f}|{role}|{s}"})
    return fonts, cells


def fingerprint(cells):
    h = hashlib.sha256()
    for c in cells:
        h.update(c["id"].encode("utf-8"))
        h.update(b"\0")
    return h.hexdigest()[:16]


# --------------------------------------------------------------------------- capture
def read_captures():
    paths = sorted(glob.glob(str(RECORDS / "*__geom.json")))
    live, dead = [], []
    for p in paths:
        pay = json.load(open(p, encoding="utf-8"))["payload"]
        (live if pay.get("apparatus") == "live" else dead).append((Path(p).name, pay))
    return live, dead


def agreement(live):
    """Do the live runs agree on every text cell? A disagreement is a finding, not noise."""
    seen, conflicts = {}, []
    for name, pay in live:
        for fontname, row in (pay.get("fonts") or {}).items():
            for s, w in (row.get("strings") or {}).items():
                key = (fontname, s)
                if key in seen and seen[key][1] != w:
                    conflicts.append((key, seen[key], (name, w)))
                seen.setdefault(key, (name, w))
    return seen, conflicts


def derive_quantum(values):
    """The grid, taken FROM the data rather than chosen by hand.

    ⚠⚠ DERIVED FROM SHOWN FontString WIDTHS ONLY, and that is not fastidiousness - it is
    the whole result. A first cut fed the control probe's never-shown width in with the
    rest; because ANY q/n also "fits" a set, one off-grid value simply drove the search to
    a 5x finer grid that accommodated it, reported 289/289 on the grid, and destroyed the
    finding. ★ A contaminating value does not announce itself as an outlier here; it
    silently makes the answer finer. ⟶ Derive on the clean population, TEST the other one.

    Ascending n returns the LARGEST q that fits, which is the fundamental grid: if q fits
    then so does q/2, so the search must stop at the first success rather than the best.
    """
    nonzero = [v for v in values if v[2] > 0]
    if not nonzero:
        return None
    smallest = min(v[2] for v in nonzero)
    for n in range(1, 65):
        q = smallest / n
        if max(abs(v[2] / q - round(v[2] / q)) for v in nonzero) < 1e-4:
            return q
    return None


def off_grid(values, q):
    """Which values are NOT on the derived grid. The check that can say NO."""
    return [v for v in values if v[2] > 0 and abs(v[2] / q - round(v[2] / q)) > 1e-3]


# --------------------------------------------------------------------------- font source
def load_advances(fontfiles):
    """Unhinted advance widths, in ems, straight out of the client archive."""
    try:
        arc = mpyq.MPQArchive(str(FONT_ARCHIVE))
    except Exception as e:
        print(f"check_sheet: cannot open {FONT_ARCHIVE.name} - {type(e).__name__}: {e}")
        sys.exit(2)
    out = {}
    for f in sorted(fontfiles):
        blob = arc.read_file(("Fonts\\" + f).encode("latin-1"))
        if blob is None:
            for cand in arc.files or []:
                if cand.lower() == ("fonts\\" + f).lower().encode("latin-1"):
                    blob = arc.read_file(cand)
                    break
        if blob is None:
            out[f] = None
            continue
        tt = TTFont(io.BytesIO(blob), fontNumber=0, lazy=True)
        upem = tt["head"].unitsPerEm
        hmtx, cmap = tt["hmtx"], tt.getBestCmap()
        out[f] = {chr(cp): hmtx[gn][0] / upem for cp, gn in cmap.items() if gn in hmtx.metrics}
    return out


def em_sum(adv, text):
    total = 0.0
    for ch in text:
        if ch not in adv:
            return None
        total += adv[ch]
    return total


# --------------------------------------------------------------------------- the model
def base_quanta(adv, k, text):
    """Per-glyph rounding onto the grid, then summed - the shape the residuals implied."""
    return sum(round(k * adv[ch]) for ch in text)


def fit_constants(adv, size, samples):
    """Fit k (quanta per em) and c (overhead, quanta) to minimise the WORST error.

    Worst-case rather than least-squares: a layout is broken by its worst cell, not by
    its average one. c is solved in closed form for each k, so this is a 1-D sweep.
    """
    best = None
    lo, hi = size * 1.0, size * 2.6
    steps = 6000
    for i in range(steps + 1):
        k = lo + (hi - lo) * i / steps
        ds = [target - base_quanta(adv, k, text) for text, target in samples]
        c = round((max(ds) + min(ds)) / 2.0)
        worst = max(abs(c - d) for d in ds)
        if best is None or worst < best[0]:
            best = (worst, k, c)
        if worst == 0:
            break
    return best  # (worst, k, c)


# --------------------------------------------------------------------------- report
def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--cells", action="store_true", help="print every cell with its residual")
    ap.add_argument("--font", help="restrict to one font object")
    args = ap.parse_args()

    decl = read_declaration()
    fonts, cells = expand_text_cells(decl)
    print(f"declaration  {DECL.relative_to(REPO).as_posix()}  v{decl.get('version')}")
    print(f"             text cells: {len(fonts)} fonts x "
          f"{len(cells) // max(len(fonts), 1)} strings = {len(cells)}")
    print(f"             fingerprint sha256:{fingerprint(cells)}   (append-only; a change here"
          f" means the standard moved)")

    live, dead = read_captures()
    if not live:
        print("\ncheck_sheet: no LIVE geom capture in addons/landing/records - nothing to check"
              f" ({len(dead)} record(s) with a dead apparatus)")
        sys.exit(2)
    measured, conflicts = agreement(live)
    configs = {(p.get("scale"), p.get("resolution")) for _, p in live}
    print(f"\ncapture      {len(live)} live record(s), {len(dead)} dead")
    for scale, res in sorted(configs, key=str):
        print(f"             scale {scale}  res {res}")
    if len(configs) == 1:
        print("             ⚠ ONE configuration only - every number below is conditional on it")
    if conflicts:
        print(f"             ⚠ {len(conflicts)} cell(s) DISAGREE between runs:")
        for key, a, b in conflicts[:5]:
            print(f"               {key}: {a[0]} said {a[1]}, {b[0]} said {b[1]}")

    shown = [(f, s, w) for (f, s), (_, w) in measured.items()
             if isinstance(w, (int, float))]
    control = []
    for name, pay in live:
        ctl = pay.get("control") or {}
        for kname in ("shownWidth", "hiddenWidth"):
            if isinstance(ctl.get(kname), (int, float)):
                control.append(("control", kname, float(ctl[kname])))
    q = derive_quantum(shown)
    if not q:
        print("\ncheck_sheet: no common grid in the captured widths - the model cannot be"
              " expressed in quanta, so nothing below would mean anything")
        sys.exit(2)
    bad_shown = off_grid(shown, q)
    bad_ctl = off_grid(control, q)
    live_shown = len([v for v in shown if v[2] > 0])
    print(f"\ngrid         q = {q!r} UI units, derived from the SHOWN FontString widths")
    print(f"             {live_shown - len(bad_shown)}/{live_shown} of them on the grid")
    for f, s, w in bad_shown:
        print(f"             OFF-GRID  {f}.{s!r} = {w!r}")
    print(f"             control probe: {len(control) - len(bad_ctl)}/{len(control)}"
          f" on the same grid")
    for f, s, w in sorted(set(bad_ctl)):
        print(f"             OFF-GRID  {f}.{s} = {w!r}")
    if bad_ctl:
        print("             ⚠ the never-shown frame is the one off it, which is the geom"
              " runsheet's")
        print("               existing ruling reached from a second direction:"
              " calibrate on a SHOWN frame")

    declared = {(c["font"], EMPTY_KEY if c["text"] == "" else c["text"]): c for c in cells}
    missing = [k for k in declared if k not in measured]
    print(f"\ncoverage     {len(declared)} declared, {len(declared) - len(missing)} captured,"
          f" {len(missing)} not measured")
    for k in missing[:10]:
        print(f"             MISSING  {k[0]} / {k[1]!r}")

    fontfiles = {}
    for name, pay in live:
        for fontname, row in (pay.get("fonts") or {}).items():
            f = (row.get("file") or "").split("\\")[-1]
            if f:
                fontfiles[fontname] = (f, row.get("size"))
    ADV = load_advances({f for f, _ in fontfiles.values()})

    print("\nmodel        unhinted advances from the client archive; per-glyph rounding on the")
    print("             grid; k and c fitted on the CALIBRATION strings ONLY, error reported")
    print("             on the held-out SPECIMEN strings.")
    print()
    print(f"{'font object':<24} {'file':<14} {'size':>5} {'k':>9} {'c':>4} "
          f"{'fit':>5} {'held-out':>9} {'worst UI':>9}")

    worst_overall, rows_shown = 0, 0
    for fontname in sorted(fontfiles):
        if args.font and args.font != fontname:
            continue
        ffile, size = fontfiles[fontname]
        adv = ADV.get(ffile)
        if not adv or not size:
            print(f"{fontname:<24} {ffile:<14} {'-':>5} {'font not readable - no model':>40}")
            continue

        def samples_for(role):
            out = []
            for c in cells:
                if c["font"] != fontname or c["role"] != role or c["text"] == "":
                    continue
                w = measured.get((fontname, c["text"]))
                if not w or em_sum(adv, c["text"]) is None:
                    continue
                out.append((c["text"], round(w[1] / q)))
            return out

        cal, spec = samples_for("calibration"), samples_for("specimen")
        if len(cal) < 3:
            print(f"{fontname:<24} {ffile:<14} {size:5.1f} "
                  f"{'too few calibration cells to fit':>44}")
            continue
        fit_worst, k, c = fit_constants(adv, size, cal)
        held = [(abs(c + base_quanta(adv, k, t) - tgt), t, tgt, c + base_quanta(adv, k, t))
                for t, tgt in spec]
        held_worst = max((h[0] for h in held), default=0)
        worst_overall = max(worst_overall, held_worst)
        rows_shown += 1
        print(f"{fontname:<24} {ffile:<14} {size:5.1f} {k:9.4f} {c:4} "
              f"{fit_worst:5} {held_worst:9} {held_worst * q:9.4f}")

        if args.cells:
            for e, t, tgt, pred in sorted(held, reverse=True):
                mark = "   " if e == 0 else " ! "
                print(f"   {mark}{e:>3} q  {t!r:52} client {tgt:>5} q  model {pred:>5} q")

    if not rows_shown:
        print("(no font object could be modelled)")
        sys.exit(2)

    print()
    print(f"DRIFT        worst held-out error {worst_overall} q = {worst_overall * q:.4f} UI units")
    print("             offline text is " +
          ("EXACT on every held-out specimen" if worst_overall == 0
           else f"+/-{worst_overall * q:.2f} UI units, MARKED, per font object"))
    print("             ⚠ a divergence is a fact about two records disagreeing, not a defect")


if __name__ == "__main__":
    main()
