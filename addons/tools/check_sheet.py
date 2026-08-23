# -*- coding: utf-8 -*-
r"""check_sheet.py - the UI test sheet's OFFLINE MODEL against the CLIENT's own measurement.

    py addons\tools\check_sheet.py                 every configuration, then the model
    py addons\tools\check_sheet.py --cells         every cell, with its residual
    py addons\tools\check_sheet.py --font X        one font object only
    py addons\tools\check_sheet.py --config N      model the Nth configuration (default: newest)

★★★ WHY. `addons/COA_DevDump/sheet_decl.lua` declares specimens; two renderers consume it - the
offline rect model and the client - and THIS is the diff between them. It is the loop AP-13 asks
for: the agent sees what it did, against a fact, instead of tuning success by churn.

★★ IT READS `sheet` AND `geom` RECORDS THROUGH ONE PATH. `task_sheet` is the instrument; the
seven `task_geom` runs that predate it carry the same font-object measurements and are not
thrown away for being older.

★★ THE SWEEP IS THE POINT OF THE CONFIGURATION BLOCK. One open question remains - what q IS.
`1/q` = 1.5936 device px per returned unit while `uiScale x screenH/768` = 2.2534, so the obvious
mapping is wrong. ⟶ If q moves with the configuration it is a device-pixel artefact and the
rasterisation size is derivable; if q holds fixed it is a font-engine constant. **Runs at two
configurations settle it, and this reports q per configuration so the answer is read, not argued.**

⚠⚠ AGREEMENT IS CHECKED WITHIN A CONFIGURATION, NEVER ACROSS ONE. Two runs at the same uiScale
that disagree is a finding. Two runs at DIFFERENT uiScales that disagree is the experiment
working. A first cut compared every run to every other and would have reported 275 disagreements
the moment a sweep began - the alarm firing on the data it was built to collect.

★★ IT REPORTS DRIFT, NEVER FAILURE - `check_interface.py`'s rule, and for the same reason. A
divergence between our model of the client and the client is a FACT about two records
disagreeing. Exit is non-zero only when the run cannot be BELIEVED (no capture, dead apparatus,
unreadable font), never when it merely disagrees.

★ THE FIT IS HELD OUT. Constants are fitted on the CALIBRATION strings alone and the error is
reported on the SPECIMEN strings, which never touched the fit. Fitting on everything and
reporting the residual would measure the fitter, not the model - and "broad insight rather than
one addon" (Battlewrath, 2026-08-23) is exactly a claim about strings the calibration never saw.

⚠ THE MODEL IS UNHINTED. Advances come from the font's own `hmtx`, scaled linearly. The client
rasterises through FreeType and hinting moves per-glyph advances, so a residual is EXPECTED and
its size is the deliverable.

⚠ READ-ONLY. The client archive is opened for reading; nothing is written anywhere.
"""
import argparse
import glob
import hashlib
import io
import json
import re
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

# `task_geom` and `task_sheet` cannot use "" as a table key in a readable record, so both
# store the empty string under this name. An adapter fact about the capture, not a property
# of the standard.
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
def config_key(pay):
    """What the sweep varies. Read off the record, never assumed."""
    cfg = pay.get("config") or {}
    scale = cfg.get("uiParentEffectiveScale", pay.get("scale"))
    res = cfg.get("resolution", pay.get("resolution"))
    return (round(float(scale), 6) if isinstance(scale, (int, float)) else None, res)


def read_captures():
    """Every live capture that carries font-object measurements, grouped by configuration."""
    live, dead = [], []
    for pattern in ("*__sheet.json", "*__geom.json"):
        for p in sorted(glob.glob(str(RECORDS / pattern))):
            doc = json.load(open(p, encoding="utf-8"))
            pay = doc["payload"]
            entry = (Path(p).name, doc.get("header", {}).get("task", "?"), pay)
            (live if pay.get("apparatus") == "live" else dead).append(entry)
    groups = {}
    for name, task, pay in live:
        groups.setdefault(config_key(pay), []).append((name, task, pay))
    return groups, dead


def measurements(runs):
    """Every (font, string) -> width in one configuration, plus any disagreement inside it."""
    seen, conflicts = {}, []
    for name, _task, pay in runs:
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


# ★★★ q's IDENTITY - AND THE VALUE IS NOT KEPT HERE.
#
#     1/q  x  GetScreenWidth()  ==  TEXT_GRID_COLUMNS      (GetScreenWidth in UI units)
#
# ⚠⚠ THE CONSTANT IS PARSED OUT OF THE ADDON'S OWN AUTHORITY (Battlewrath, 2026-08-23:
# *"the addon bench / the addon should be self descriptive"*). It lives in
# `dungeonrun_interface_inventory.md` -> `Constants, sourced`, beside the dropdown's three
# widths and the template-size rule, because that is the document a person opens while
# BUILDING a surface - not ROUTER, which you read at boot and never again.
#
# ★ Holding a second copy here is the exact fault `check_cites.py` was built for, one level
# up: a number that nothing owns, correct at the instant it is typed. So the doc and the tool
# cannot disagree - there is only one of them.
#
# ★ And the claim is still TESTED, not trusted: `derive_quantum` reads q out of the measured
# widths independently and the report prints both. The document supplies the claim; the
# captures supply the derive; a disagreement is loud.
INVENTORY = (Path(__file__).resolve().parents[1] / "planning"
             / "dungeonrun_interface_inventory.md")
_GRID_RE = re.compile(r"TEXT_GRID_COLUMNS\s*=\s*([0-9]+(?:\.[0-9]+)?)")


def text_grid_columns():
    """The settled constant, read from the inventory. ⚠ REFUSES rather than defaulting.

    A fallback here would be the copy this function exists to abolish, and it would be
    silent: the tool would keep printing agreement against a number the document no longer
    states. Renaming or deleting the inventory line STOPS the checker, which is the point.
    """
    try:
        text = INVENTORY.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        print(f"check_sheet: cannot read {INVENTORY.name} - {type(e).__name__}: {e}")
        sys.exit(2)
    m = _GRID_RE.search(text)
    if not m:
        print(f"check_sheet: {INVENTORY.name} no longer states `TEXT_GRID_COLUMNS = <n>` in"
              " its `Constants, sourced` section.")
        print("             That line is the settled claim and this tool does not carry a"
              " copy of it, so there is")
        print("             nothing to check against. Restore it, or update this tool"
              " deliberately - not by default.")
        sys.exit(2)
    return float(m.group(1))


def formula_quantum(cfg, columns):
    """q predicted from the configuration alone - no capture needed.

    `columns` is passed in rather than read here, so the settled value is fetched ONCE per
    run and every row in the report is checked against the same number.
    """
    w = (cfg or {}).get("screenWidth")
    return (w / columns) if isinstance(w, (int, float)) and w else None


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
def grid_for(runs):
    """q, plus the values that sit off it, for one configuration."""
    measured, conflicts = measurements(runs)
    shown = [(f, s, w) for (f, s), (_, w) in measured.items() if isinstance(w, (int, float))]
    control = []
    for _name, _task, pay in runs:
        ctl = pay.get("control") or {}
        for kname in ("shownWidth", "hiddenWidth"):
            if isinstance(ctl.get(kname), (int, float)):
                control.append(("control", kname, float(ctl[kname])))
    q = derive_quantum(shown)
    return measured, conflicts, shown, control, q


def constants_view(groups, order, qs, cells):
    """k, c and the held-out error for every font object at EVERY configuration.

    ★★★ THE QUESTION THIS ANSWERS. k and c are not configuration-invariant - but the two
    configurations measured so far that share a q gave BYTE-IDENTICAL constants for all
    eleven fonts, so k is q-derived rather than free. What is not yet explained is that
    1440x1080 @ 1.00 sits apart from the other three in every framing tried, and that
    configuration is the only one at scale 1.0 AND the only one at 4:3 - resolution and
    scale are confounded in it.

    ⟶ A SCALE SPAN AT ONE RESOLUTION SEPARATES THEM, and this is its reader. Watch the
    `em_UI` column (k x q, the em in UI units): if it holds across a 1440x1080 span and only
    breaks at scale 1.0, the outlier is a scale effect; if it breaks everywhere on 1440, it
    is the resolution.

    ⚠ Constants are FITTED on the calibration strings, so a fitted k sits somewhere in a
    plateau of equally-good values rather than on a point. Two configurations agreeing to
    three decimals is meaningful; the last digit is not.
    """
    print("\nconstants across configurations")
    print("   k = quanta per em (fitted) · c = overhead in quanta · held = worst held-out"
          " error, quanta")
    print("   em_UI = k x q, the em in UI units - the column that should be stable if the")
    print("   model is one thing being quantised differently\n")

    fontfiles, per_cfg = {}, {}
    for key in order:
        runs = groups[key]
        measured, _c, _s, _ctl, q = grid_for(runs)
        per_cfg[key] = (measured, q)
        for _n, _t, pay in runs:
            for fontname, row in (pay.get("fonts") or {}).items():
                f = (row.get("file") or "").split("\\")[-1]
                if f:
                    fontfiles[fontname] = (f, row.get("size"))
    ADV = load_advances({f for f, _ in fontfiles.values()})

    head = "".join(f"{(str(k[1]) + '@' + format(k[0], '.2f')):>26}" for k in order)
    print(f"{'font object':<24}{head}")
    print(f"{'':24}" + "".join(f"{'k / c / held / em_UI':>26}" for _ in order))

    for fontname in sorted(fontfiles):
        ffile, size = fontfiles[fontname]
        adv = ADV.get(ffile)
        if not adv or not size:
            continue
        row_cells, sig = [], []
        for key in order:
            measured, q = per_cfg[key]
            cal, spec = [], []
            for c in cells:
                if c["font"] != fontname or c["text"] == "":
                    continue
                w = measured.get((fontname, c["text"]))
                if not w or em_sum(adv, c["text"]) is None:
                    continue
                (cal if c["role"] == "calibration" else spec).append(
                    (c["text"], round(w[1] / q)))
            if len(cal) < 3:
                row_cells.append("-")
                sig.append(None)
                continue
            _fw, k, cc = fit_constants(adv, size, cal)
            held = max((abs(cc + base_quanta(adv, k, t) - tgt) for t, tgt in spec), default=0)
            row_cells.append(f"{k:.3f}/{cc}/{held}/{k * q:.3f}")
            sig.append((round(k, 3), cc))
        # ⚠ configurations that share a q MUST share constants; if they do not, the fault is
        # in the instrument or the fit, not in the client
        byq = {}
        contradiction = False
        for key, s in zip(order, sig):
            if s is None:
                continue
            qq = round(qs[key], 9)
            if qq in byq and byq[qq] != s:
                contradiction = True
            byq[qq] = s
        mark = " !!" if contradiction else "   "
        print(f"{fontname:<24}{mark}" + "".join(f"{c:>26}" for c in row_cells))

    print("\n   !! = two configurations share a q but disagree on k/c - that would be an"
          " instrument fault, not a client fact")
    print("   q per configuration:")
    for key in order:
        print(f"      {str(key[1]):<12} scale {key[0]:<7} q = {qs[key]!r}")


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--cells", action="store_true", help="print every cell with its residual")
    ap.add_argument("--font", help="restrict to one font object")
    ap.add_argument("--config", type=int, help="model the Nth configuration (see the table)")
    ap.add_argument("--constants", action="store_true",
                    help="k/c/held-out for every font at EVERY configuration (the scale-span reader)")
    args = ap.parse_args()

    decl = read_declaration()
    fonts, cells = expand_text_cells(decl)
    print(f"declaration  {DECL.relative_to(REPO).as_posix()}  v{decl.get('version')}")
    print(f"             text cells: {len(fonts)} fonts x "
          f"{len(cells) // max(len(fonts), 1)} strings = {len(cells)}")
    print(f"             fingerprint sha256:{fingerprint(cells)}   (append-only; a change here"
          f" means the standard moved)")

    groups, dead = read_captures()
    if not groups:
        print("\ncheck_sheet: no LIVE capture in addons/landing/records - nothing to check"
              f" ({len(dead)} record(s) with a dead apparatus)")
        print("\nnext         in-game:  /coadump r sheet    then  /reload")
        print("             the bench watcher (py addons/landing/pull.py watch) lands it")
        sys.exit(2)

    order = sorted(groups, key=lambda k: (str(k[1]), str(k[0])))
    print(f"\nconfigurations   {len(order)} captured"
          + ("   ⚠ ONE only - every model number below is conditional on it" if len(order) == 1
             else ""))
    columns = text_grid_columns()
    print(f"{'':13}claim: q = GetScreenWidth()/{columns:g}"
          f"   (read from {INVENTORY.name} -> Constants, sourced; this tool holds no copy)")
    print(f"{'':13}{'#':>2} {'resolution':<12} {'uiScale':>9} {'runs':>5} {'cells':>6} "
          f"{'q measured':>15} {f'q = scrW/{columns:g}':>15} {'agree?':>8}")
    qs = {}
    formula_breaks = []
    for i, key in enumerate(order, 1):
        runs = groups[key]
        measured, conflicts, shown, control, q = grid_for(runs)
        qs[key] = q
        scale, res = key
        tasks = {t for _n, t, _p in runs}
        cfg = next((p.get("config") for _n, _t, p in runs if p.get("config")), None)
        fq = formula_quantum(cfg, columns)
        qtxt = f"{q:.10f}" if q else "no common grid"
        if q and fq:
            rel = abs(q - fq) / q
            agree = "yes" if rel < 1e-5 else f"NO {rel:.1e}"
            if rel >= 1e-5:
                formula_breaks.append((key, q, fq, rel))
            print(f"{'':13}{i:>2} {str(res):<12} {scale if scale else '?':>9} {len(runs):>5} "
                  f"{len(shown):>6} {qtxt:>15} {fq:15.10f} {agree:>8}")
        else:
            print(f"{'':13}{i:>2} {str(res):<12} {scale if scale else '?':>9} {len(runs):>5} "
                  f"{len(shown):>6} {qtxt:>15} {'-':>15} {'-':>8}")
        if conflicts:
            print(f"{'':16}⚠ {len(conflicts)} cell(s) disagree BETWEEN RUNS AT THIS SAME"
                  f" configuration - that is a finding, not the sweep:")
            for ckey, a, b in conflicts[:3]:
                print(f"{'':18}{ckey}: {a[0]} said {a[1]}, {b[0]} said {b[1]}")
        print(f"{'':16}from: {', '.join(sorted(tasks))}")

    if formula_breaks:
        print()
        print("⚠⚠ THE SOLVED FORMULA IS BROKEN BY A CAPTURE - that outranks everything below,")
        print("   because the model computes q from the configuration and would now be wrong:")
        for key, q, fq, rel in formula_breaks:
            print(f"   {str(key[1]):<12} scale {key[0]}  measured {q!r}  formula {fq!r}"
                  f"  ({rel:.2e})")

    # ---- the sweep's own question ------------------------------------------------
    if len(order) > 1 and all(qs.values()):
        print()
        distinct = sorted({round(q, 9) for q in qs.values()})
        if len(distinct) == 1:
            print("q ACROSS CONFIGS  q is FIXED across every captured configuration")
            print("                  ⟶ it is a font-engine constant, not a device-pixel"
                  " artefact; '±N q, marked' is the final answer")
        else:
            print("q ACROSS CONFIGS  q MOVES with the configuration:")
            for key in order:
                scale, res = key
                q = qs[key]
                print(f"                  {str(res):<12} uiScale {scale}  q={q!r}"
                      f"  1/q={1 / q:.6f}")
            print("                  ⟶ it is a device-pixel artefact; the rasterisation size"
                  " is derivable, and hinted")
            print("                    advances should close the residual")

    # ---- the constants, across every configuration -------------------------------
    if args.constants:
        constants_view(groups, order, qs, cells)
        return

    # ---- the model, on one configuration ----------------------------------------
    pick = order[(args.config - 1) if args.config else -1]
    if args.config and not (1 <= args.config <= len(order)):
        print(f"\ncheck_sheet: --config {args.config} is out of range (1..{len(order)})")
        sys.exit(2)
    runs = groups[pick]
    measured, _conflicts, shown, control, q = grid_for(runs)
    if not q:
        print("\ncheck_sheet: no common grid in this configuration's widths - the model cannot"
              " be expressed in quanta, so nothing below would mean anything")
        sys.exit(2)

    bad_shown, bad_ctl = off_grid(shown, q), off_grid(control, q)
    live_shown = len([v for v in shown if v[2] > 0])
    print(f"\ngrid         configuration {order.index(pick) + 1}: {pick[1]} at uiScale {pick[0]}")
    print(f"             q = {q!r} UI units, derived from the SHOWN FontString widths")
    print(f"             {live_shown - len(bad_shown)}/{live_shown} of them on the grid")
    for f, s, w in bad_shown:
        print(f"             OFF-GRID  {f}.{s!r} = {w!r}")
    if control:
        print(f"             control probe: {len(control) - len(bad_ctl)}/{len(control)}"
              f" on the same grid")
    for f, s, w in sorted(set(bad_ctl)):
        print(f"             OFF-GRID  {f}.{s} = {w!r}")
    if bad_ctl:
        print("             ⚠ the never-shown frame is the one off it - the geom runsheet's")
        print("               existing ruling from a second direction: measure a SHOWN frame")

    declared = {(c["font"], EMPTY_KEY if c["text"] == "" else c["text"]): c for c in cells}
    missing = [k for k in declared if k not in measured]
    print(f"\ncoverage     {len(declared)} declared, {len(declared) - len(missing)} captured,"
          f" {len(missing)} not measured")
    for k in missing[:10]:
        print(f"             MISSING  {k[0]} / {k[1]!r}")

    fontfiles = {}
    for _name, _task, pay in runs:
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
            print(f"{fontname:<24} {ffile:<14} {'-':>5}  font not readable - no model")
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
            print(f"{fontname:<24} {ffile:<14} {size:5.1f}  too few calibration cells to fit")
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

    # ---- the dispatch instruction, so nothing has to be remembered ---------------
    print()
    if len(order) == 1:
        print("next         q's identity is still open, and one more configuration settles it.")
        print("             change the client's resolution or UI scale, then, in-game:")
        print()
        print("                 /coadump r sheet")
        print("                 /reload")
        print()
        print("             same command at every setting - the run reads the configuration")
        print("             off the client. The watcher lands it; re-run this tool.")
    else:
        print("next         run more configurations the same way (/coadump r sheet, /reload),")
        print("             or grow the standard: append to sheet_decl.lua, then re-capture.")


if __name__ == "__main__":
    main()
