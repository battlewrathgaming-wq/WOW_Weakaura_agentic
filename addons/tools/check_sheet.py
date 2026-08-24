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
import math
import json
import re
import subprocess
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

# ★ The screenshot pairing, reusing `ui_run.py`'s constants rather than restating them in a
# second dialect: the client names a shot `WoWScrnShot_MMDDYY_HHMMSS.jpg`, and a request on a
# second boundary can land one second later.
SHOTS = CLIENT_DATA.parent / "Screenshots"
SHOT_STEM = re.compile(r"^WoWScrnShot_(\d{6}_\d{6})\.jpg$", re.I)
SHOT_WINDOW = 1


def paired_shot(stem):
    """The screenshot file for a request stem, or None. ⚠ Reports the offset it used."""
    if not stem or not SHOTS.exists():
        return None, None
    have = {m.group(1) for f in SHOTS.glob("*.jpg")
            for m in [SHOT_STEM.match(f.name)] if m}
    if stem in have:
        return stem, 0
    date_s, tm = stem.split("_")
    h, m_, s = int(tm[0:2]), int(tm[2:4]), int(tm[4:6])
    for d in range(-SHOT_WINDOW, SHOT_WINDOW + 1):
        if d == 0:
            continue
        total = (h * 3600 + m_ * 60 + s + d) % 86400
        cand = "%s_%02d%02d%02d" % (date_s, total // 3600, (total % 3600) // 60, total % 60)
        if cand in have:
            return cand, d
    return None, None

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


def expand_control_cells(decl):
    """Sheet two's cell set: every AceGUI widget x every width in the vocabulary."""
    ctl = decl.get("control") or {}
    widgets = as_list(ctl.get("widgets"))
    widths = as_list(ctl.get("widths"))
    cells = []
    for w in widths:
        how = (w or {}).get("how")
        val = (w or {}).get("value")
        for name in widgets:
            cells.append({"kind": "control", "widget": name, "how": how, "asked": val,
                          "id": f"control|{name}|{how}|{val}"})
    return widgets, as_list(ctl.get("containers")), cells


def expand_art_cells(decl):
    """Sheet three's subjects: every stock template and every AceGUI widget.

    ⚠ v2 listed templates as bare strings; v3 lists `{ name, type }` because the frame TYPE
    is part of building the specimen (a Button template created as a Frame draws nothing).
    ★ The id is built from the NAME alone, deliberately: the cell SET did not change, so the
    fingerprint must not either. What changed is the RECIPE, and `declVersion` on each record
    is what separates a v2 measurement of those rows from a v3 one.
    """
    art = decl.get("art") or {}
    subjects = []
    for t in as_list(art.get("templates")):
        subjects.append(("template", t.get("name") if isinstance(t, dict) else t))
    subjects += [("acegui", w) for w in as_list(art.get("widgets"))]
    return [{"kind": "art", "source": s, "subject": n, "id": f"art|{s}|{n}"}
            for s, n in subjects if n]


def expand_collapse_cells(decl):
    """Sheet seven's cells: width x state. The sections are fixed by the declaration."""
    c = decl.get("collapse") or {}
    widths, states = as_list(c.get("widths")), as_list(c.get("states"))
    secs = [s.get("name") for s in as_list(c.get("sections")) if isinstance(s, dict)]
    out = [{"kind": "collapse", "width": w, "state": st, "id": f"collapse|{w}|{st}"}
           for w in widths for st in states]
    return secs, widths, states, out


def expand_tab_cells(decl):
    """Sheet six's cells: set x width, calibration before specimen. Fixes the fingerprint."""
    tb = decl.get("tab") or {}
    widths = as_list(tb.get("widths"))
    out, sets = [], []
    for role in ("calibration", "specimen"):
        for s in as_list(tb.get(role)):
            name = (s or {}).get("name")
            if name:
                sets.append((role, name))
                for w in widths:
                    out.append({"kind": "tab", "role": role, "set": name, "width": w,
                                "id": f"tab|{role}|{name}|{w}"})
    return sets, widths, out


def expand_wrap_cells(decl):
    """Sheet five's cells: font x string x width. The order fixes the fingerprint."""
    w = decl.get("wrap") or {}
    fonts = as_list(w.get("fonts"))
    widths = as_list(w.get("widths"))
    out = []
    for f in fonts:
        for role in ("calibration", "specimen"):
            for s in as_list(w.get(role)):
                for wd in widths:
                    out.append({"kind": "wrap", "font": f, "role": role,
                                "text": s, "width": wd,
                                "id": f"wrap|{f}|{role}|{s}|{wd}"})
    return fonts, widths, out


def expand_behaviour_cells(decl):
    """Sheet four's subjects: the widgets that have a commit grammar at all."""
    b = decl.get("behaviour") or {}
    return [{"kind": "behaviour", "subject": s, "id": f"behaviour|{s}"}
            for s in as_list(b.get("subjects"))]


def fingerprint(cells):
    h = hashlib.sha256()
    for c in cells:
        h.update(c["id"].encode("utf-8"))
        h.update(b"\0")
    return h.hexdigest()[:16]


# ★★★ THE FINGERPRINT IS PER KIND, and that is forced by growth rather than chosen.
# One fingerprint over every cell would have MOVED the moment sheet two was appended -
# and "the standard moved" would then mean "someone added a kind", which is exactly the
# event the guard is supposed to permit. ⟶ A kind's fingerprint answers a question about
# THAT kind: `text` must read f1b430431c2a2186 for as long as its lists are untouched,
# whatever else the declaration grows.
KIND_FINGERPRINT_NOTE = "append a kind and only that kind's fingerprint is new"


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


LUA = REPO / ".tools" / "lua51" / "lua5.1.exe"
WRAP_MODEL = REPO / "addons" / "tools" / "smoke" / "wrap_predict.lua"


def wrap_predictions(scale, jobs, aspect=None):
    """Ask the OFFLINE model, in `frames.lua`, for (lines, height) per cell.

    ⚠ Returns None rather than guessing if the model cannot be run - a missing prediction is
    reported as missing. A table of zeros would read as a model that answers badly instead of
    one that did not answer.
    """
    if not LUA.exists() or not WRAP_MODEL.exists():
        return None
    # ⚠ The ASPECT goes with the scale: q = 3*aspect/(10*uiScale), so a prediction made
    # at the nominal 16:9 is 0.0123% out on a screen that is not 16:9 - small, and it moves
    # break points on long strings.
    payload = [f"{scale!r}\t{aspect!r}" if aspect else f"{scale!r}"]
    for font, width, text in jobs:
        payload.append(f"{font}\t{width}\t{text}")
    try:
        r = subprocess.run([str(LUA), str(WRAP_MODEL)],
                           input="\n".join(payload), capture_output=True,
                           text=True, encoding="utf-8", timeout=120,
                           cwd=str(WRAP_MODEL.parent))
    except (OSError, subprocess.TimeoutExpired) as e:
        print(f"      ⚠ offline model could not be run: {e}")
        return None
    if r.returncode != 0:
        print(f"      ⚠ offline model failed: {(r.stderr or '').strip()[:160]}")
        return None
    out = []
    for line in (r.stdout or "").splitlines():
        a, _, b = line.partition("\t")
        out.append((a, float(b) if b else 0.0))
    return out if len(out) == len(jobs) else None


RANGE_WALK = REPO / "addons" / "COA_DevDump" / "range_walk.lua"
RANGE_RUN = REPO / "addons" / "tools" / "smoke" / "range_run.lua"


def range_walk_offline():
    """Run the declared walk through `range_walk.lua` - the SAME file the client loads.

    ★★★ THIS NEEDS NO CAPTURE, and that is the point of sheet eight. The player's function
    is pure arithmetic, so the design can be checked before anyone plays it; only the grab
    TARGETS need the client.
    """
    if not LUA.exists() or not RANGE_RUN.exists():
        return None
    try:
        r = subprocess.run([str(LUA), str(RANGE_RUN)], capture_output=True, text=True,
                           encoding="utf-8", timeout=60, cwd=str(REPO))
    except (OSError, subprocess.TimeoutExpired) as e:
        print(f"   ⚠ the walk could not be run: {e}")
        return None
    if r.returncode != 0:
        print(f"   ⚠ the walk failed: {(r.stderr or '').strip()[:200]}")
        return None
    rows = []
    for line in (r.stdout or "").splitlines():
        f = line.split("\t")
        if len(f) >= 8:
            rows.append({"i": int(f[0]), "op": f[1], "envLo": float(f[2]),
                         "envHi": float(f[3]), "breadth": float(f[4]),
                         "at": float(f[5]), "step": float(f[6]), "n": int(f[7]),
                         "sel": f[8] if len(f) > 8 else "",
                         "clamped": (len(f) > 9 and f[9] == "true")})
    return rows


def range_view(groups, order):
    """Sheet eight: the player's FUNCTION, walked over a mock sample. No display.

    ⚠ Runs whether or not a capture exists. A capture adds the grab-target geometry; the
    walk itself is arithmetic and answers today.
    """
    rows = range_walk_offline()
    if rows is None:
        print("\ncheck_sheet: could not run the walk (need .tools/lua51 and smoke/range_run.lua)")
        return
    print(f"\n{'=' * 96}")
    print("THE WALK — the player's function over the mock sample, run OFFLINE")
    print("⚠ no capture needed: `range_walk.lua` uses no WoW API, so the same file answers here")
    print(f"\n   {'#':>2} {'op':<16}{'envelope':>12}{'breadth':>9}{'at':>6}{'step':>6}"
          f"{'n':>4}   selection")
    prev = None
    stuck = []
    for r in rows:
        env = f"{r['envLo']:.0f}-{r['envHi']:.0f}"
        # ★★ TWO KINDS OF NOTHING, and only one is a finding:
        #    REDUNDANT   the op asked for the state it was already in - the CALLER's doing
        #    CLAMPED     the control refused at an edge - the CONTROL's doing
        # ⚠ Without `clamped` these look identical, and a walk script that repeats itself
        # would read as a defect in the control.
        same = (prev is not None
                and r["envLo"] == prev["envLo"] and r["envHi"] == prev["envHi"]
                and r["breadth"] == prev["breadth"] and r["at"] == prev["at"])
        mark = ""
        if same and r.get("clamped"):
            mark = "  ← CLAMPED, no-op"
            stuck.append(r)
        elif same:
            mark = "  ← redundant (the walk asked for what it had)"
        sel = r["sel"]
        if len(sel) > 30:
            sel = sel[:29] + "…"
        print(f"   {r['i']:>2} {r['op']:<16}{env:>12}{r['breadth']:>9.0f}{r['at']:>6.0f}"
              f"{r['step']:>6.0f}{r['n']:>4}   {sel}{mark}")
        prev = r

    if stuck:
        print(f"\n   ⚠⚠ {len(stuck)} STEP(S) WERE CLAMPED TO NOTHING"
              f" - the control refused and gave no sign")
        for r in stuck:
            print(f"      step {r['i']:>2}  `{r['op']}`  refused at the envelope's edge")
        print("   ★ `an action with no answer is indistinguishable from one that failed`")
        print("     (concepts/input-commit.md). At a clamped edge the press is a genuine no-op,")
        print("     so the answer is a DISABLED control, not silence - AceGUI tints a disabled")
        print("     widget, and that is the whole fix.")
    else:
        print("\n   ⟶ no step was clamped to nothing on this walk")

    # The grab targets, if a capture carries them.
    any_geo = False
    for key in order:
        for name, _task, pay in groups[key]:
            rg = pay.get("range") or {}
            if not rg.get("targets") and not pay.get("registration"):
                continue
            any_geo = True
            shot = pay.get("shot") or {}
            if shot.get("requestedAt"):
                found, off = paired_shot(shot["requestedAt"])
                if found:
                    print(f"\n   SCREENSHOT   WoWScrnShot_{found}.jpg"
                          + (f"   (⚠ {off:+d}s from the request)" if off else "   (exact)"))
                    print(f"      {SHOTS / ('WoWScrnShot_' + found + '.jpg')}")
                    print("      ★ with the key below, this image is RECTIFIABLE:"
                          " two pins give scale and offset.")
                else:
                    # ⚠ NAMED, not silent. `ui.lua`: one shot survives per SECOND, so a
                    # missing file is a real and expected outcome, not an error.
                    print(f"\n   ⚠ SCREENSHOT NOT FOUND for request"
                          f" {shot['requestedAt']} (±{SHOT_WINDOW}s)")
                    print("      One shot survives per second on this client - a second"
                          " request inside the same")
                    print("      second yields NO file, silently. Counting is the check.")

            reg = pay.get("registration") or {}
            if reg.get("pins"):
                # ★★ THE KEY, printed so a screenshot is rectifiable AGAINST THE RECORD.
                # An image has no coordinates; two located pins give scale and offset, and
                # every other pixel becomes a sheet coordinate. ⚠ Search the image for the
                # colour you were TOLD to expect - never one you guessed.
                print(f"\n   REGISTRATION KEY from {name}")
                if reg.get("sheet"):
                    print(f"      sheet        {reg['sheet']}")
                order = ["tl", "top", "tr", "left", "centre", "right",
                         "bl", "bottom", "br"]
                for pin in order:
                    if pin in reg["pins"]:
                        print(f"      {pin:<12}{reg['pins'][pin]}")
                extra = sorted(set(reg["pins"]) - set(order))
                for pin in extra:
                    print(f"      {pin:<12}{reg['pins'][pin]}   ⚠ not in the expected set")
                print("      ★ the CENTRE is the larger square and the only mark not on an"
                      " edge - identifiable")
                print("        without a colour lookup at all.")

            print(f"\n   GRAB TARGETS from {name}   ({rg.get('n', '?')} measured)")
            for tname, rect in sorted((rg.get("targets") or {}).items()):
                print(f"      {tname:<12}{rect}")
            ov = rg.get("overlaps") or []
            if ov:
                # ⚠⚠ The arrangement's ONE claim, failing. Handles above and below the bar
                # exist so that Z-order decides nothing; an overlap means it has to again.
                print(f"\n      ⚠⚠ {len(ov)} PAIR(S) OVERLAP - the arrangement's whole claim")
                for pair in ov:
                    print(f"         {pair}")
                print("      ★ envelope ABOVE / slice BELOW exists so no two targets share a")
                print("        pixel. An overlap means a precedence rule is needed after all.")
            else:
                print("\n      ⟶ NO TWO TARGETS OVERLAP."
                      "  His arrangement holds: no precedence rule needed.")
    if not any_geo:
        # ⚠⚠ CORRECTED TWICE. §615 read his *"no display"* as "no widget" and reported the
        # targets as out of scope. He meant NO MAP: *"Display wise I meant display of it
        # actually filtering content on a map."* ⟶ The CONTROL is in scope; drawing filtered
        # nodes on a map is not. The demo builds the bar, the handles and the steppers, and
        # shows its selection as a LIST rather than as pins.
        print("\n   ☐ no capture carries the grab-target geometry yet."
              "   In-game:  /coadump r sheet")


def collapse_view(groups, order):
    """Sheet seven: what a section WEIGHS open and shut.

    ★★★ The pane's own question. F·30 measured the object pane over half empty; UL-13
    measured two tab strips at 94 of 220. Collapse is the only lever left that does not
    remove a control, and the number that decides it is what a SHUT section weighs.

    ⚠ WA's mechanism is an option table with `hidden = collapsedFunc`
    (`WeakAurasOptions/CommonOptions.lua:293`); `panespec` has no option table. This measures
    the ACEGUI form. The shape is borrowed, the mechanism is not the same, and saying so is
    the difference between prior art and a copied answer.
    """
    any_run = False
    for key in order:
        for name, _task, pay in groups[key]:
            cp = pay.get("collapse") or {}
            cells = cp.get("cells") or []
            if not cells and not cp.get("note"):
                continue
            any_run = True
            cfg = pay.get("config") or {}
            print(f"\n{'=' * 96}")
            print(f"{name}   {cfg.get('resolution')} @ {cfg.get('uiParentEffectiveScale')}"
                  f"   decl v{pay.get('declVersion', '?')}")
            if cp.get("note"):
                print(f"   ⚠ {cp['note']}")
                if not cells:
                    continue

            widths = sorted({c.get("width") for c in cells if c.get("width")})
            states = []
            for c in cells:
                if c.get("state") not in states:
                    states.append(c.get("state"))

            print(f"\n   STACK HEIGHT - how far the sections actually reached")
            print(f"      {'state':<12}" + "".join(f"{w:>10}" for w in widths)
                  + "     what it is")
            what = {"open": "every section expanded - the ceiling",
                    "shut": "every section collapsed to its header - the FLOOR",
                    "one-open": "first open, rest shut - what a person sees"}
            base = {}
            for st in states:
                row = {c.get("width"): c for c in cells if c.get("state") == st}
                cellstr = ""
                for w in widths:
                    c = row.get(w) or {}
                    h = c.get("stackH")
                    if c.get("error"):
                        cellstr += f"{'ERR':>10}"
                    elif h is None:
                        cellstr += f"{'-':>10}"
                    else:
                        cellstr += f"{h:>10.0f}"
                        base.setdefault(st, {})[w] = h
                print(f"      {str(st):<12}{cellstr}     {what.get(st, '')}")

            # ★ THE NUMBER THE DESIGN TURNS ON: what collapsing actually buys.
            if "open" in base and "shut" in base:
                print(f"\n   ★ WHAT COLLAPSE BUYS")
                for w in widths:
                    o, s = base["open"].get(w), base["shut"].get(w)
                    if o and s:
                        one = (base.get("one-open") or {}).get(w)
                        print(f"      at {w}:  open {o:.0f}  ->  shut {s:.0f}"
                              f"   saves {o - s:.0f}px ({100.0 * (o - s) / o:.0f}%)"
                              + (f"   ·  one-open {one:.0f}" if one else ""))
                # ⚠ The 600 is object.lua's fixed pane height; the comparison is the point
                # of the sheet, not decoration.
                for w in widths:
                    o = base["open"].get(w)
                    one = (base.get("one-open") or {}).get(w)
                    if o:
                        print(f"      ⚠ the object pane is a FIXED 240 x 600"
                              f" (object.lua:582). At {w}, open needs {o:.0f}"
                              + (f" and one-open needs {one:.0f}" if one else "")
                              + f" - {'FITS' if o <= 600 else 'DOES NOT FIT'} open.")
                        break

            # Per-section, from the state that has them all
            per = next((c for c in cells if c.get("state") == "open"), None)
            if per and per.get("sections"):
                print(f"\n   PER SECTION at {per.get('width')} (open)")
                print(f"      {'section':<12}{'fields':>7}{'header h':>10}")
                for s in per["sections"]:
                    hh = s.get("headerH")
                    print(f"      {str(s.get('name')):<12}{s.get('fields', 0):>7}"
                          f"{('-' if hh is None else f'{hh:.0f}'):>10}")
                print("      ★ the header height IS the price of a shut section - WA's"
                      " `1. Desaturate: OFF` idiom means")
                print("        it still carries its state, so a shut section informs"
                      " rather than merely hides.")

            bad = [c for c in cells if c.get("error")]
            if bad:
                print(f"\n   ⚠⚠ {len(bad)} state(s) failed to measure:")
                for c in bad[:4]:
                    print(f"      {c.get('state')} @ {c.get('width')}: {c['error']}")

    if not any_run:
        print("\nno capture carries sheet seven. In-game:  /coadump r sheet   then  /reload")


def tabs_view(groups, order):
    """Sheet six: does the strip WRAP, and what does it cost before content starts?

    ★★★ THIS IS THE TEXT METRIC'S CONSUMER TEST. AceGUI sizes each tab from its TEXT
    (`PanelTemplates_TabResize`) and wraps the strip when the row will not fit
    (`AceGUIContainer-TabGroup.lua:207`). A model 5% out on a string can be a whole ROW out
    on a strip, and a row moves every control below it.

    ⚠ `rows` is counted from distinct tab TOPS - what a person would count by looking -
    never from an AceGUI internal, so it survives the library changing how it stores them.
    """
    any_run = False
    for key in order:
        for name, _task, pay in groups[key]:
            tb = pay.get("tab") or {}
            cells = tb.get("cells") or []
            if not cells and not tb.get("note"):
                continue
            any_run = True
            cfg = pay.get("config") or {}
            print(f"\n{'=' * 96}")
            print(f"{name}   {cfg.get('resolution')} @ {cfg.get('uiParentEffectiveScale')}"
                  f"   decl v{pay.get('declVersion', '?')}"
                  f"   AceGUI {(cfg.get('libs') or {}).get('AceGUI-3.0')}")
            if tb.get("note"):
                print(f"   ⚠ {tb['note']}")
                if not cells:
                    continue

            widths = sorted({c.get("width") for c in cells if c.get("width")})
            names = []
            for c in cells:
                k = (c.get("role"), c.get("set"))
                if k not in names:
                    names.append(k)

            print(f"\n   ROWS the strip needed   (⚠ 2+ means every control below moved down)")
            print(f"      {'set':<14}{'role':<12}{'tabs':>5}"
                  + "".join(f"{w:>8}" for w in widths))
            for role, s in names:
                row = {c.get("width"): c for c in cells
                       if c.get("set") == s and c.get("role") == role}
                first = next(iter(row.values()), {})
                cellstr = ""
                for w in widths:
                    c = row.get(w) or {}
                    if c.get("error"):
                        cellstr += f"{'ERR':>8}"
                    elif c.get("rows") is None:
                        cellstr += f"{'-':>8}"
                    else:
                        r = c["rows"]
                        cellstr += f"{(str(r) + ('!' if r > 1 else '')):>8}"
                print(f"      {str(s):<14}{str(role):<12}{first.get('n', '?'):>5}{cellstr}")
            print("      ★ `!` marks a strip that wrapped. 240 is the unified pane and the"
                  " remote; 280 is drive.")
            # ★★★ HIS BOUND, APPLIED WHERE THE NUMBERS ARE (Battlewrath, 2026-08-24):
            # *"there is no intent of a third nested row. There might be a use for action
            # tabs to spread from row 1 to row 2, but the same group of containers."*
            # ⚠ ROWS are not LEVELS: a strip wrapping to row 2 is still ONE group with one
            # selection; a TabGroup inside a TabGroup is a SECOND group. Two rows is in
            # scope, a third row is not, and a third LEVEL was never proposed.
            over = [c for c in cells if (c.get("rows") or 0) >= 3]
            if over:
                print(f"\n      ⚠⚠ {len(over)} strip(s) need THREE OR MORE rows - OUT OF"
                      f" SCOPE by his ruling, not merely tight:")
                for c in over[:6]:
                    print(f"         {str(c.get('set')):<14} @ {c.get('width')}"
                          f"  {c.get('rows')} rows")
                print("         ★ `three-wide`/`eight` are the forcing calibration sets and"
                      " are SUPPOSED to land here.")
                print("         A specimen set landing here is a design fact, not a"
                      " tolerance to widen.")
            else:
                print("\n      ⟶ no strip needs a third row (his bound holds on this run)")

            # ★ The vertical price, which is the number a pane budget needs.
            print(f"\n   STRIP COST - px from the group's top to where CONTENT starts")
            print(f"      {'set':<14}" + "".join(f"{w:>8}" for w in widths))
            for role, s in names:
                row = {c.get("width"): c for c in cells
                       if c.get("set") == s and c.get("role") == role}
                cellstr = ""
                for w in widths:
                    c = row.get(w) or {}
                    sc = c.get("stripCost")
                    cellstr += f"{'-':>8}" if sc is None else f"{sc:>8.0f}"
                print(f"      {str(s):<14}{cellstr}")

            bad = [c for c in cells if c.get("error")]
            if bad:
                print(f"\n   ⚠⚠ {len(bad)} strip(s) failed to measure:")
                for c in bad[:4]:
                    print(f"      {c.get('set')} @ {c.get('width')}: {c['error']}")

            # ★★ SUB-TABS - his second half, and the question is whether the inner strip
            # renders AT ALL inside a container, not just whether it fits.
            nest = tb.get("nest") or []
            if nest:
                print(f"\n   SUB-TABS - a TabGroup inside a TabGroup's content")
                print(f"      {'width':>6}{'outer rows':>12}{'inner rows':>12}"
                      f"{'inner drew':>12}{'both strips':>13}{'content left':>14}")
                for r in nest:
                    if r.get("error"):
                        print(f"      {r.get('asked'):>6}   ⚠ {r['error']}")
                        continue
                    tsc = r.get("totalStripCost")
                    cl = r.get("contentLeft")
                    print(f"      {r.get('asked'):>6}{str(r.get('outerRows')):>12}"
                          f"{str(r.get('innerRows')):>12}"
                          f"{str(r.get('innerRendered')):>12}"
                          f"{('-' if tsc is None else f'{tsc:.0f}'):>13}"
                          f"{('-' if cl is None else f'{cl:.0f}'):>14}")
                print("      ⚠ `content left` is what remains for the sub-page's own controls"
                      " after BOTH strips.")
                print("      ★ TWO LEVELS is the whole design - a third was never proposed."
                      " `inner rows` 2 at 240 is a")
                print("        strip WRAPPING inside one group, which his ruling allows;"
                      " it is not a third level.")

    if not any_run:
        print("\nno capture carries sheet six. In-game:  /coadump r sheet   then  /reload")


def wrap_view(groups, order, qs=None):
    """Sheet five: where the client BREAKS A LINE - the one thing UL-1 could not tell us.

    ★★★ AL-45 ruled a measured-height cell kind YES and bounded the offline half to
    `measured, quantised, MARKED`. None of that is possible until the client has said where
    it wraps, because a wrap point is a DECISION and not a number. ⚠ So this view reports
    OBSERVATION ONLY. It fits nothing and predicts nothing - the moment it carries a model,
    the model has been fitted on the same run it is checked against, which reads as success.

    ★ `lines` is height/oneLine ROUNDED, and it is printed with the raw height beside it so a
    non-integer ratio is visible rather than hidden by the rounding. A ratio that is not
    close to a whole number means `oneLine` is not the line advance, and that would matter
    more than any row in the table.
    """
    any_run = False
    seen_qv = {}          # uiScale -> q_v, for the cross-configuration line below
    for key in order:
        for name, _task, pay in groups[key]:
            w = pay.get("wrap") or {}
            cells = w.get("cells") or []
            if not cells and not w.get("note"):
                continue
            any_run = True
            cfg = pay.get("config") or {}
            print(f"\n{'=' * 96}")
            print(f"{name}   {cfg.get('resolution')} @ {cfg.get('uiParentEffectiveScale')}"
                  f"   decl v{pay.get('declVersion', '?')}")
            if w.get("note"):
                print(f"   ⚠ {w['note']}")
                if not cells:
                    continue

            methods = w.get("methods") or {}
            if methods:
                have = [m for m, ok in sorted(methods.items()) if ok]
                lack = [m for m, ok in sorted(methods.items()) if not ok]
                print(f"\n   FontString methods PRESENT: {', '.join(have) or '(none)'}")
                print(f"                       ABSENT: {', '.join(lack) or '(none)'}")
                print("   ⚠ absent is a FACT about this client, not a gap in the run -"
                      " nothing here was called blind")

            fonts = w.get("fonts") or {}
            for fname in sorted(fonts):
                frow = fonts[fname] or {}
                if frow.get("error"):
                    print(f"\n   {fname:<26} ⚠ {frow['error']}")
                    continue
                one = frow.get("oneLine")
                # ★★★ THE QUESTION THAT DECIDES THE OFFLINE MODEL. UL-1 settled that a
                # text WIDTH is a whole multiple of q = GetScreenWidth()/2560. If the LINE
                # ADVANCE sits on that same grid, an offline wrapped height is
                # `lines x (n * q)` and both halves are predictable from the same constant.
                # ⚠ Printed with its distance from a whole number so a NO reads as clearly
                # as a YES - this is the number, not an argument for one.
                grid = ""
                q = (qs or {}).get(key)
                if q and one:
                    n = one / q
                    grid = (f"   = {n:.4f} q"
                            + ("  ON GRID" if abs(n - round(n)) < 1e-4
                               else f"  OFF GRID by {abs(n - round(n)):.4f} q"))
                print(f"\n   {fname:<26} size {frow.get('size')}"
                      f"   one line = {one}{grid}"
                      f"   ({Path(str(frow.get('file') or '?')).name})")
                mine = [c for c in cells if c.get("font") == fname]
                widths = sorted({c.get("width") for c in mine})
                print(f"      {'string':<44}{'role':<12}"
                      + "".join(f"{wd:>8}" for wd in widths))
                seen = []
                for c in mine:
                    if c.get("text") not in seen:
                        seen.append(c.get("text"))
                for s in seen:
                    row = {c.get("width"): c for c in mine if c.get("text") == s}
                    role = (row.get(widths[0]) or {}).get("role", "?")
                    shown = s if len(s) <= 42 else s[:41] + "…"
                    cellstr = ""
                    for wd in widths:
                        c = row.get(wd) or {}
                        h = c.get("height")
                        if h is None:
                            cellstr += f"{'-':>8}"
                        elif one:
                            n = h / one
                            mark = "" if abs(n - round(n)) < 0.02 else "?"
                            cellstr += f"{str(round(n)) + mark:>8}"
                        else:
                            cellstr += f"{h:>8.0f}"
                    print(f"      {shown:<44}{role:<12}{cellstr}")

                # ⚠ The raw heights, once, under the line counts - so `lines` can be
                # checked rather than believed.
                odd = [c for c in mine if one and c.get("height") is not None
                       and abs(c["height"] / one - round(c["height"] / one)) >= 0.02]
                if odd:
                    print(f"      ⚠⚠ {len(odd)} cell(s) whose height is NOT a whole"
                          f" multiple of one line - marked `?` above. `oneLine` may not be"
                          f" the line advance.")
                    for c in odd[:4]:
                        print(f"         w={c['width']:<5} h={c['height']}"
                              f"  ratio {c['height'] / one:.3f}   {str(c['text'])[:40]}")

            # ★★★ THE VERTICAL QUANTUM, DERIVED - not compared to the horizontal one.
            # Every font came back OFF the width grid by the SAME small amount, and a
            # consistent offset is a different grid rather than error. `derive_quantum`
            # answers "the largest q on which all these values are whole multiples", which
            # is the same question asked of heights instead of widths.
            advances = sorted({round(f["oneLine"], 9) for f in (fonts or {}).values()
                               if f.get("oneLine")})
            if advances:
                qv = derive_quantum([(None, None, a) for a in advances])
                q = (qs or {}).get(key)
                print(f"\n   LINE ADVANCE, {len(advances)} distinct value(s):"
                      f" {', '.join(f'{a:.9f}' for a in advances)}")
                if qv:
                    seen_qv[float(cfg.get("uiParentEffectiveScale") or 0)] = qv
                    print(f"      vertical quantum derived  q_v = {qv!r}   1/q_v ="
                          f" {1 / qv:.6f}")
                    print("      advances as multiples of q_v:  "
                          + ", ".join(f"{a / qv:.4f}" for a in advances))
                    if q:
                        print(f"      width quantum (UL-1)      q   = {q!r}   1/q   ="
                              f" {1 / q:.6f}")
                        print(f"      q_v / q = {qv / q:.9f}"
                              + ("   SAME GRID" if abs(qv / q - 1) < 1e-6
                                 else "   ⟶ A DIFFERENT GRID from the width quantum"))
                    # ★★★ THE RULE, TESTED RATHER THAN FITTED. q_v came from the
                    # advances; the advance is now PREDICTED from the font's declared
                    # SIZE and the residual printed. A rule that is tested can fail
                    # visibly on the next run; a rule that is fitted never can.
                    sized = []
                    for fn, fr in sorted((fonts or {}).items()):
                        s, a = fr.get("size"), fr.get("oneLine")
                        if s and a:
                            sized.append((fn, float(s), float(a)))
                    if sized:
                        print("\n      RULE UNDER TEST:  advance = round(size / q_v) * q_v")
                        print(f"      {'font':<26}{'size':>7}{'size/q_v':>11}"
                              f"{'predicted':>12}{'measured':>12}{'residual':>11}"
                              f"{'relative':>11}")
                        # ⚠ RELATIVE, and 1e-6 rather than an absolute 1e-6 that an
                        # earlier pass used. q_v is one measured advance over an integer,
                        # so it carries the client's ~1e-7 relative error and n*q_v carries
                        # it too; an absolute threshold on a value of magnitude 12 was
                        # asking for 8e-8 relative and reported float noise as failure.
                        # ★ The teeth are intact: an off-by-one-QUANTUM error is a residual
                        # of ~q_v, relative ~5e-2 - five orders of magnitude above this.
                        REL = 1e-6
                        worst, off = 0.0, 0
                        for fn, s, a in sized:
                            n = s / qv
                            # ⚠ Explicit half-up, not Python's banker's round(). NOT a
                            # finding: no reported size divides q_v exactly, so no tie
                            # occurs in this data and both rules agree on every row. The
                            # choice is UNTESTED and marked, not asserted.
                            pred = math.floor(n + 0.5) * qv
                            res = a - pred
                            rel = abs(res) / a if a else abs(res)
                            worst = max(worst, rel)
                            if rel > REL:
                                off += 1
                            print(f"      {fn:<26}{s:>7.0f}{n:>11.3f}"
                                  f"{pred:>12.6f}{a:>12.6f}{res:>11.2e}{rel:>11.1e}")
                        print(f"      ⟶ {len(sized) - off} of {len(sized)} font(s) fit"
                              f" (relative <= {REL:.0e}); worst {worst:.1e}"
                              f"   [one quantum off would be ~{qv / 12:.0e}]")
                        if off:
                            print("      ⚠⚠ A FONT IS OFF THE RULE - that is the finding,"
                                  " not a tolerance to widen.")
                else:
                    print("      no grid fits these advances at n <= 64 - reported, not"
                          " forced")

                # ⚠ THE BASIS, printed with the number so it cannot be quoted without it.
                print(f"      ⚠ from ONE configuration and {len(advances)} distinct"
                      f" advance(s). UL-1's width quantum rests on ten configurations;"
                      f" this does not.")
                print("        A grid derived from two values is a grid two values happen"
                      " to lie on. Sweep before trusting.")

            # ★★★ THE DIFF - the offline model against the client, which is the whole
            # reason the sheet has two renderers. Everything above is the client
            # describing itself; this is the only part that can say our model is wrong.
            jobs, cellrefs = [], []
            for c in cells:
                fr = (fonts or {}).get(c.get("font")) or {}
                if fr.get("size") and c.get("height") is not None:
                    jobs.append((c.get("font"), c["width"], c["text"]))
                    cellrefs.append((c, fr))
            asp = None
            res = str(cfg.get("resolution") or "")
            if "x" in res:
                try:
                    rw, rh = (float(v) for v in res.split("x")[:2])
                    asp = rw / rh
                except ValueError:
                    asp = None
            preds = wrap_predictions(cfg.get("uiParentEffectiveScale") or 1.0, jobs, asp)
            if preds is None:
                print("\n   ⚠ NO OFFLINE COMPARISON THIS RUN - the model did not answer."
                      " Reported, never filled in.")
            elif cellrefs:
                one = {}
                for c, fr in cellrefs:
                    one[c.get("font")] = fr.get("oneLine")
                agree_l = agree_h = 0
                bad = []
                for (c, fr), (nl, ph) in zip(cellrefs, preds):
                    adv = one.get(c.get("font")) or 0
                    measured_lines = round(c["height"] / adv) if adv else None
                    try:
                        pl = int(nl)
                    except ValueError:
                        pl = None
                    if pl is not None and pl == measured_lines:
                        agree_l += 1
                    else:
                        bad.append((c, measured_lines, pl))
                    if abs(ph - c["height"]) <= 1e-4 * max(c["height"], 1):
                        agree_h += 1
                n = len(cellrefs)
                print(f"\n   ★ OFFLINE MODEL vs CLIENT, {n} cell(s)")
                print(f"      line count   {agree_l}/{n} agree"
                      f"   ({100.0 * agree_l / n:.1f}%)")
                print(f"      height       {agree_h}/{n} agree within 1e-4 relative")
                if bad:
                    # ⚠ The DISAGREEMENTS are the deliverable, so they are named rather
                    # than counted. A percentage with no instances is not a finding.
                    print(f"      ⚠ {len(bad)} disagreement(s); first few:")
                    for c, ml, pl in bad[:6]:
                        print(f"        {str(c['font'])[:22]:<22} w={c['width']:<5}"
                              f" client {ml} line(s), model {pl}"
                              f"   {str(c['text'])[:34]}")
                    print("      ⟶ the residual is the WIDTH model: unhinted advances plus a"
                          " fitted linear correction, per (font, uiScale).")
                    print("        The client rasterises through FreeType and hinting moves"
                          " per-glyph advances; these rows are that, not the grid.")

            # ★ What GetStringWidth answers after SetWidth - the question the declaration
            # refused to assume. Reported, never resolved here.
            with_sw = [c for c in cells if c.get("stringWidth") is not None]
            if with_sw:
                clamped = sum(1 for c in with_sw
                              if c["stringWidth"] <= c["width"] + 0.5)
                print(f"\n   GetStringWidth after SetWidth: {clamped} of {len(with_sw)}"
                      f" cell(s) came back <= the set width")
                print("   ⚠ ALL <= means it reports the laid-out line; SOME OVER means it"
                      " reports the unwrapped advance. Read it, do not assume it.")

    # ★★★ THE CROSS-CONFIGURATION LINE - the whole reason for a sweep. UL-1 asked the same
    # question of the WIDTH quantum and answered it by running configurations, not by arguing.
    if len(seen_qv) >= 2:
        print(f"\n{'=' * 96}")
        print(f"q_v ACROSS {len(seen_qv)} UI SCALES - is it DERIVABLE, or measured per run?")
        print(f"   {'uiScale':>10}{'q_v':>22}{'1/q_v':>12}{'(1/q_v)/uiScale':>18}")
        ratios = []
        for sc in sorted(seen_qv):
            qv = seen_qv[sc]
            r = (1 / qv) / sc if sc else float("nan")
            ratios.append(r)
            print(f"   {sc:>10.4f}{qv:>22.13f}{1 / qv:>12.6f}{r:>18.9f}")
        spread = max(ratios) - min(ratios)
        if spread < 1e-5:
            k = sum(ratios) / len(ratios)
            print(f"\n   ⟶ CONSTANT to {spread:.1e} across {len(ratios)} scales:"
                  f"  1/q_v = uiScale x {k:.6f}")
            print(f"     so  q_v = 1 / (uiScale x {k:.6f})  - DERIVABLE, and an offline"
                  f" wrapped height needs no per-config capture")
        else:
            print(f"\n   ⟶ NOT constant - the ratio spreads {spread:.2e}. q_v is measured"
                  f" per configuration and the offline model must say so.")
        print("   ⚠ One RESOLUTION only. This spans uiScale; whether q_v also holds across"
              " resolutions is untested.")

    if any_run and qs:
        print("\n   ⚠ `q` is this configuration's measured text quantum (UL-1). ONE"
              " configuration carries sheet five,")
        print("     so an ON GRID here is a single observation, not the span UL-1's width"
              " finding rests on.")

    if not any_run:
        print("\nno capture carries sheet five. In-game:  /coadump r sheet   then  /reload")


def behaviour_view(groups, order):
    """Sheet four: does the widget OBEY the grammar `concepts/input-commit.md` states?

    ★★ The grammar was read off ONE widget's source. Every line of it is a claim about what
    the code says; these rows are what the LIVE client did when driven. `/coadump r api`'s
    shape - claim vs observed vs agrees - because it is the same question.

    ⚠ The `how` column is not decoration. `api` means a real client call drove it. `handler`
    means we invoked the registered script ourselves, which proves the HANDLER and not the
    client's dispatch, and must not be read as more. A row that cannot be driven at all is
    listed under `unmeasurable` rather than left out - the same discipline as F.Unmeasured().
    """
    any_run = False
    for key in order:
        for name, _task, pay in groups[key]:
            rows = pay.get("behaviour") or []
            if not rows and not pay.get("behaviourSkipped"):
                continue
            any_run = True
            cfg = pay.get("config") or {}
            print(f"\n{'=' * 96}")
            print(f"{name}   {cfg.get('resolution')} @ {cfg.get('uiParentEffectiveScale')}"
                  f"   decl v{pay.get('declVersion', '?')}"
                  f"   AceGUI {(cfg.get('libs') or {}).get('AceGUI-3.0')}")
            if pay.get("behaviourSkipped"):
                print(f"   ⚠ SKIPPED: {pay['behaviourSkipped']}")
                continue

            print(f"\n   {'subject':<10}{'check':<28}{'claim':>10}{'observed':>12}"
                  f"{'how':>9}   verdict")
            disagreed = 0
            for r in rows:
                agrees = r.get("agrees")
                if not agrees:
                    disagreed += 1
                mark = "agrees" if agrees else "★ DISAGREES"
                print(f"   {str(r.get('subject')):<10}{str(r.get('id')):<28}"
                      f"{str(r.get('claim')):>10}{str(r.get('observed')):>12}"
                      f"{str(r.get('how')):>9}   {mark}")
                if r.get("note"):
                    print(f"   {'':<10}{'':<28}{r['note']}")

            unmeas = pay.get("behaviourUnmeasurable") or {}
            if unmeas:
                print(f"\n   ⚠ NOT DRIVABLE - named rather than left out:")
                for k in sorted(unmeas):
                    print(f"     {k}: {unmeas[k]}")

            print()
            if disagreed:
                print(f"   ★ {disagreed} disagreement(s). A disagreement is worth more than a"
                      f" clean sheet -")
                print(f"     it means the grammar in concepts/input-commit.md describes the"
                      f" source and not this client.")
            else:
                print(f"   {len(rows)} check(s), no disagreement - the grammar holds where it"
                      f" could be driven.")

    if not any_run:
        print("\nbehaviour    nothing captured yet. Deploy and run:")
        print("                 py addons\\deploy.py COA_DevDump")
        print("                 /coadump r sheet   then   /reload")


def art_view(groups, order):
    """Sheet three: how far the PICTURE runs past the RECT, per edge.

    ★★★ THE RULE THIS GENERALISES is already earned - `COA_DungeonRun/layout.lua:124`,
    §103 "the neighbour, not the edge": *a rect check UNDER-REPORTS a dropdown by design,
    and a pane can look wrong exactly where the arithmetic says it is fine.* Every check
    this bench owns compares rects, so the overhang has been invisible to all of them.

    ⚠ POSITIVE MEANS THE PICTURE RUNS PAST THE RECT on that edge. The dropdown is
    asymmetric - 25 either side, but +17 above and ~15 below - so one number per edge is
    the minimum honest report; a single "art is bigger" would hide which neighbour it eats.
    """
    any_run = False
    for key in order:
        for name, _task, pay in groups[key]:
            rows = pay.get("art") or []
            if not rows and not pay.get("artSkipped"):
                continue
            any_run = True
            cfg = pay.get("config") or {}
            print(f"\n{'=' * 96}")
            print(f"{name}   {cfg.get('resolution')} @ {cfg.get('uiParentEffectiveScale')}"
                  f"   decl v{pay.get('declVersion', '?')}")
            if pay.get("artSkipped"):
                print(f"   ⚠ SKIPPED: {pay['artSkipped']}")
                continue
            if pay.get("artWidgetsSkipped"):
                print(f"   ⚠ {pay['artWidgetsSkipped']}")
            # ⚠ A record written between v3's declaration change and its task fix carries
            # whole TABLES here instead of names. Normalised rather than rejected: the
            # capture is otherwise good, and a reader that crashes on one malformed field
            # throws away a run someone spent a client restart on.
            missing = []
            for m in pay.get("artMissing") or []:
                missing.append(m.get("name", str(m)) if isinstance(m, dict) else str(m))
            if missing:
                print(f"   ⚠ not on this fork: {', '.join(sorted(set(missing)))}"
                      f"   (named, never counted as zero overhang)")

            print(f"\n   {'subject':<26}{'variant':>9}{'rect w':>9}{'rect h':>8}"
                  f"{'left':>8}{'right':>8}{'top':>8}{'bottom':>8}{'regions':>9}")
            for r in rows:
                if r.get("error"):
                    print(f"   {str(r.get('subject')):<26}"
                          f"{str(r.get('variant') or r.get('source')):>9}"
                          f"   {r['error']}")
                    continue
                f_, o = r.get("frame") or {}, r.get("over") or {}

                def n(v):
                    return f"{v:.1f}" if isinstance(v, (int, float)) else "-"
                flag = ""
                if any(isinstance(o.get(e), (int, float)) and o[e] > 0.5
                       for e in ("left", "right", "top", "bottom")):
                    flag = "  <- art outside the rect"
                print(f"   {str(r.get('subject')):<26}"
                      f"{str(r.get('variant') or r.get('source')):>9}"
                      f"{n(f_.get('width')):>9}{n(f_.get('height')):>8}"
                      f"{n(o.get('left')):>8}{n(o.get('right')):>8}"
                      f"{n(o.get('top')):>8}{n(o.get('bottom')):>8}"
                      f"{r.get('regions', '-'):>9}{flag}")
                if r.get("hiddenRegions") or r.get("unplacedRegions"):
                    print(f"   {'':<26}{'':>9}   ⚠ {r.get('hiddenRegions', 0)} hidden,"
                          f" {r.get('unplacedRegions', 0)} unplaced region(s) - not unioned")

            # ★★★ THE A:B VERDICT - the difference IS the finding.
            # A template whose regions anchor to `$parentX` cannot resolve them without a
            # name: the anchors fail SILENTLY and a texture simply does not draw. This
            # compares the two builds of each template and reports the list the sheet
            # PROVES, rather than the two instances we happened to trip over.
            pairs_ = {}
            for r in rows:
                if r.get("variant"):
                    pairs_.setdefault(r["subject"], {})[r["variant"]] = r
            ab = {k: v for k, v in pairs_.items() if "named" in v and "anon" in v}
            if ab:
                print(f"\n   A:B - does a NAME change what draws?")
                print(f"   {'template':<26}{'regions':>12}{'rect w':>14}"
                      f"{'art edges (L R T B)':>26}{'verdict':>16}")
                for subj in sorted(ab):
                    a, b = ab[subj]["named"], ab[subj]["anon"]
                    ra, rb = a.get("regions"), b.get("regions")
                    wa = (a.get("frame") or {}).get("width")
                    wb = (b.get("frame") or {}).get("width")
                    both_w = isinstance(wa, (int, float)) and isinstance(wb, (int, float))

                    # ★★★ THE EDGE COMPARISON IS THE ONE THAT CATCHES THE SILENT CASE, and
                    # it was missing from the first cut. `InputBoxTemplate` reported
                    # 4 regions vs 4 and 170 wide vs 170 - identical - while the screenshot
                    # plainly showed the anonymous one missing its middle. The region still
                    # EXISTS; it simply has no working anchors, so it floats. The union's
                    # TOP edge went 0 -> 75, and nothing else moved. ⟶ Count and rect are
                    # not enough; where the picture reaches is the observable.
                    oa, ob = a.get("over") or {}, b.get("over") or {}
                    edges, edge_diff = [], False
                    for e in ("left", "right", "top", "bottom"):
                        va, vb = oa.get(e), ob.get(e)
                        if isinstance(va, (int, float)) and isinstance(vb, (int, float)):
                            if abs(va - vb) > 0.5:
                                edge_diff = True
                                edges.append(f"{va:.0f}!={vb:.0f}")
                            else:
                                edges.append(f"{va:.0f}")
                        else:
                            edges.append("-")

                    differs = (ra != rb) or (both_w and abs(wa - wb) > 0.5) or edge_diff
                    regions_col = f"{ra} vs {rb}"
                    width_col = f"{wa:.0f} vs {wb:.0f}" if both_w else "-"
                    verdict_col = "NEEDS A NAME" if differs else "same"
                    print(f"   {subj:<26}{regions_col:>12}{width_col:>14}"
                          f"{' '.join(edges):>26}{verdict_col:>16}")
                print("   ⚠ an edge shown as `a!=b` is where the two builds disagree."
                      " Region COUNT can match while")
                print("     the picture moves - an unanchored texture still exists, it just"
                      " lands somewhere else.")
                print("   ⚠ 'same' is still a measurement, not a guarantee: a texture that"
                      " vanished without moving")
                print("     the union or the rect would read as same.")


    if not any_run:
        print("\nart          nothing captured yet. Deploy and run:")
        print("                 py addons\\deploy.py COA_DevDump")
        print("                 /coadump r sheet   then   /reload")


def controls_view(groups, order):
    """Sheet two: what each AceGUI widget BECAME when asked for each width.

    ★★ THE LIBRARY MINORS HEAD EVERY BLOCK, because the row means nothing without them.
    We ship AceGUI 33 / AceConfigDialog 49; this client carries 41 / 54 inside other
    addons; LibStub keeps the highest LOADED. ⟶ the enabled addon set picks the code, so
    a control row is a measurement OF A LIBRARY VERSION and says so.

    ⚠ The `number` rows are the interesting ones. Our shipped AceConfigDialog branches on
    the strings "double"/"half"/"full" only, so WeakAuras' numeric multipliers (1.3, 0.65,
    2.6) should collapse to the bare 170. If they do, the mirror's spatial vocabulary is
    NOT expressible on the Ace we ship, and that is a design fact rather than a bug.
    """
    any_run = False
    for key in order:
        for name, _task, pay in groups[key]:
            rows = pay.get("controls") or []
            if not rows and not pay.get("controlSkipped"):
                continue
            any_run = True
            cfg = pay.get("config") or {}
            libs = cfg.get("libs") or {}
            print(f"\n{'=' * 92}")
            print(f"{name}   {cfg.get('resolution')} @ "
                  f"{cfg.get('uiParentEffectiveScale')}")
            print("   libraries LIVE: " + (", ".join(f"{k}={v}" for k, v in sorted(libs.items()))
                                           or "not recorded (run predates the gate)"))
            inputs = pay.get("controlInputs") or {}
            if inputs:
                print(f"   inputs: width_multiplier={inputs.get('widthMultiplier')}"
                      f"  hostWidth={inputs.get('hostWidth')}")
            if pay.get("controlSkipped"):
                print(f"   ⚠ SKIPPED: {pay['controlSkipped']}")
                continue

            missing = pay.get("controlsMissing") or []
            if missing:
                print(f"   ⚠ not registered by the live AceGUI: {', '.join(sorted(set(missing)))}")

            print(f"\n   {'widget':<12}{'how':>8}{'asked':>10}{'applied':>10}"
                  f"{'width':>10}{'height':>9}{'widthProp':>11}")
            for r in rows:
                if r.get("error"):
                    print(f"   {r.get('widget', '?'):<12}{str(r.get('how')):>8}"
                          f"{str(r.get('asked')):>10}   {r['error']}")
                    continue
                print(f"   {r.get('widget', '?'):<12}{str(r.get('how')):>8}"
                      f"{str(r.get('asked')):>10}{str(r.get('applied')):>10}"
                      f"{(f'{r['width']:.2f}' if isinstance(r.get('width'), (int, float)) else '-'):>10}"
                      f"{(f'{r['height']:.2f}' if isinstance(r.get('height'), (int, float)) else '-'):>9}"
                      f"{str(r.get('widthProp')):>11}")

            cont = pay.get("containers") or {}
            if cont:
                print(f"\n   {'container':<16}{'asked':>8}{'width':>10}{'height':>9}"
                      f"{'contentW':>10}{'contentH':>10}")
                for cname in sorted(cont):
                    c = cont[cname]
                    if c.get("error"):
                        print(f"   {cname:<16}   {c['error']}")
                        continue
                    def n(v):
                        return f"{v:.2f}" if isinstance(v, (int, float)) else "-"
                    print(f"   {cname:<16}{n(c.get('askedWidth')):>8}{n(c.get('width')):>10}"
                          f"{n(c.get('height')):>9}{n(c.get('contentWidth')):>10}"
                          f"{n(c.get('contentHeight')):>10}")

    if not any_run:
        print("\ncontrol      nothing captured yet. Deploy and run:")
        print("                 py addons\\deploy.py COA_DevDump")
        print("                 /coadump r sheet   then   /reload")
        print("             ⚠ COA_DevDump embeds no Ace and borrows the client's, so an")
        print("               addon that ships Ace3 must be enabled - COA_DungeonRun does.")


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--cells", action="store_true", help="print every cell with its residual")
    ap.add_argument("--font", help="restrict to one font object")
    ap.add_argument("--config", type=int, help="model the Nth configuration (see the table)")
    ap.add_argument("--behaviour", action="store_true",
                    help="sheet four: does a widget obey the input-commit grammar")
    ap.add_argument("--art", action="store_true",
                    help="sheet three: how far the picture runs past the rect, per edge")
    ap.add_argument("--controls", action="store_true",
                    help="sheet two: what each AceGUI widget became at each width")
    ap.add_argument("--range", action="store_true",
                    help="sheet eight: the player's function, walked over a mock sample")
    ap.add_argument("--collapse", action="store_true",
                    help="sheet seven: what a section weighs open, shut and one-open")
    ap.add_argument("--tabs", action="store_true",
                    help="sheet six: does a tab strip wrap, and what does it cost")
    ap.add_argument("--wrap", action="store_true",
                    help="sheet five: where the client breaks a line (observation only)")
    ap.add_argument("--constants", action="store_true",
                    help="k/c/held-out for every font at EVERY configuration (the scale-span reader)")
    args = ap.parse_args()

    decl = read_declaration()
    fonts, cells = expand_text_cells(decl)
    widgets, containers, ccells = expand_control_cells(decl)
    print(f"declaration  {DECL.relative_to(REPO).as_posix()}  v{decl.get('version')}")
    print(f"             text     {len(fonts)} fonts x {len(cells) // max(len(fonts), 1)}"
          f" strings = {len(cells):>4} cells   sha256:{fingerprint(cells)}")
    if ccells:
        print(f"             control  {len(widgets)} widgets x"
              f" {len(ccells) // max(len(widgets), 1)} widths = {len(ccells):>4} cells"
              f"   sha256:{fingerprint(ccells)}")
        print(f"                      + {len(containers)} container(s):"
              f" {', '.join(containers)}")
    bcells = expand_behaviour_cells(decl)
    if bcells:
        print(f"             behaviour {len(bcells):>3} subject(s)"
              f"                      sha256:{fingerprint(bcells)}")
    csecs, cwidths, cstates, ccells2 = expand_collapse_cells(decl)
    if ccells2:
        print(f"             collapse {len(csecs)} sections x {len(cwidths)} widths x"
              f" {len(cstates)} states = {len(ccells2):>3} cells"
              f"   sha256:{fingerprint(ccells2)}")
    tsets, twidths, tcells = expand_tab_cells(decl)
    if tcells:
        print(f"             tab      {len(tsets)} sets x {len(twidths)} widths ="
              f" {len(tcells):>5} cells   sha256:{fingerprint(tcells)}")
    wfonts, wwidths, wcells = expand_wrap_cells(decl)
    if wcells:
        print(f"             wrap     {len(wfonts)} fonts x"
              f" {len(wcells) // max(len(wfonts) * max(len(wwidths), 1), 1)} strings x"
              f" {len(wwidths)} widths = {len(wcells):>4} cells"
              f"   sha256:{fingerprint(wcells)}")
    acells = expand_art_cells(decl)
    if acells:
        print(f"             art      {len(acells):>4} subjects"
              f"                       sha256:{fingerprint(acells)}")
    print(f"             append-only; a kind's fingerprint changes only when THAT kind does")

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

    # ---- sheet eight: the player's function -----------------------------------------
    if getattr(args, "range", False):
        range_view(groups, order)
        return

    # ---- sheet seven: what does a collapsed section weigh? -------------------------
    if args.collapse:
        collapse_view(groups, order)
        return

    # ---- sheet six: do tabs work, and can we predict them? -------------------------
    if args.tabs:
        tabs_view(groups, order)
        return

    # ---- sheet five: where does the client break a line? ---------------------------
    if args.wrap:
        wrap_view(groups, order, qs)
        return

    # ---- sheet four: does the widget obey the grammar? -----------------------------
    if args.behaviour:
        behaviour_view(groups, order)
        return

    # ---- sheet three: art vs rect -------------------------------------------------
    if args.art:
        art_view(groups, order)
        return

    # ---- sheet two: what a widget BECAME ------------------------------------------
    if args.controls:
        controls_view(groups, order)
        return

    # ---- sheet two's status, always, so an uncaptured kind is never silent --------
    if ccells:
        with_ctl = [(k, r) for k in order for r in groups[k] if (r[2].get("controls"))]
        skipped = {(r[2].get("controlSkipped") or "")[:70]
                   for k in order for r in groups[k] if r[2].get("controlSkipped")}
        if with_ctl:
            print(f"\ncontrol      captured in {len(with_ctl)} run(s) - "
                  f"`--controls` for the table")
        else:
            print(f"\ncontrol      {len(ccells)} cells DECLARED, none captured yet"
                  f" (sheet two; run `/coadump r sheet` after a deploy)")
            for s in sorted(skipped):
                print(f"             last skip reason: {s}")

    if bcells:
        with_b = [1 for k in order for r in groups[k] if r[2].get("behaviour")]
        bad = [1 for k in order for r in groups[k]
               for c in (r[2].get("behaviour") or []) if not c.get("agrees")]
        if with_b:
            print(f"behaviour    captured in {len(with_b)} run(s),"
                  f" {len(bad)} disagreement(s) - `--behaviour` for the table")
        else:
            print(f"behaviour    {len(bcells)} subject(s) DECLARED, none captured yet"
                  f" (sheet four)")

    if acells:
        with_art = [1 for k in order for r in groups[k] if r[2].get("art")]
        if with_art:
            print(f"art          captured in {len(with_art)} run(s) - `--art` for the table")
        else:
            print(f"art          {len(acells)} subjects DECLARED, none captured yet"
                  f" (sheet three)")

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
