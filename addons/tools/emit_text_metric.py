# -*- coding: utf-8 -*-
r"""emit_text_metric.py - the offline width model, EMITTED as Lua from the client's own fonts.

    py addons\tools\emit_text_metric.py

★★★ WHY IT IS EMITTED AND NOT WRITTEN. `smoke/frames.lua` has carried a DECLARED GUESS since it
was built - `#text x size x 0.55`, character COUNT times a constant, blind to which glyphs. Sheet
five measured what that costs: over 660 wrap cells the offline line count agreed with the client
**459 of 660 (69.5%)**, and every disagreement was the guess - `M M M M...` came back with too FEW
lines because M is wide, `iiiiiiiiii...` with too MANY because i is narrow. The vertical grid
contributed ZERO errors. ⟶ 100% of the residual is this file's job.

★★ THE NUMBERS COME FROM THE CLIENT ARCHIVE, NOT FROM A TABLE SOMEONE TYPED. `check_sheet.py`
already reads `Fonts\*.TTF` out of `locale-enUS.MPQ` and turns `hmtx` into per-character em
advances; this imports that function rather than re-deriving it. **One reader of the archive.**

⚠⚠ AND THE FIT IS HELD OUT, exactly as `check_sheet` holds it out. `k` and `c` are fitted on the
CALIBRATION strings alone and the error is reported on the SPECIMEN strings, which never touched
the fit. A model tuned on everything and scored on everything measures the fitter.

⚠ THE MODEL IS UNHINTED. The client rasterises through FreeType and hinting moves per-glyph
advances; `k` and `c` absorb the bulk of that as a linear correction, and the residual after them
is the honest error. It is reported per font, in quanta, and the emitted file carries it so nobody
reads the table as exact.

⚠ READ-ONLY on the client. Writes one file: `addons/tools/smoke/text_metric_data.lua`.
"""
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "addons" / "tools"))

import check_sheet as CS  # noqa: E402  (the one reader of the client archive)

OUT = REPO / "addons" / "tools" / "smoke" / "text_metric_data.lua"

# ★ The characters worth emitting. The full cmap is thousands of entries and the panes are
# ASCII; anything outside this falls back to the font's own average, which the Lua side does
# and MARKS. Emitting everything would make a 300 KB Lua file to serve 95 glyphs.
KEEP = "".join(chr(c) for c in range(32, 127))


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    decl = CS.read_declaration()
    groups, _dead = CS.read_captures()
    if not groups:
        print("emit_text_metric: no capture in addons/landing/records - nothing to fit against")
        return 2

    # Font object -> (file, size), read from the CAPTURES rather than assumed: which file a
    # font object resolves to is the client's business and it differs by fork.
    resolved = {}
    for key in groups:
        for _name, _task, pay in groups[key]:
            for fname, row in (pay.get("fonts") or {}).items():
                if isinstance(row, dict) and row.get("file") and row.get("size"):
                    resolved.setdefault(fname, (Path(str(row["file"])).name,
                                                round(float(row["size"]), 4)))
    if not resolved:
        print("emit_text_metric: no capture carries font files/sizes")
        return 2

    adv = CS.load_advances({f for f, _ in resolved.values()})

    text = decl.get("text") or {}
    cal = [s for s in CS.as_list(text.get("calibration")) if s]
    spec = [s for s in CS.as_list(text.get("specimen")) if s]

    # Per-configuration measured widths, in QUANTA, so the fit is on integers the way
    # check_sheet does it. Newest configuration wins where several carry the same font.
    fits = {}
    # ★★ THE WIDTH QUANTUM AS A FUNCTION OF uiScale. `k` and `c` are fitted in QUANTA, so
    # the Lua side has to turn quanta back into UI units - and offline there is no
    # `GetScreenWidth()` to divide by 2560. UL-10 found `1/q_v = uiScale x 1.875` exactly
    # for the VERTICAL grid; the width quantum keeps a constant ratio to it, so the same
    # shape holds with its own constant. ⚠ MEASURED here per configuration and emitted with
    # its spread, never assumed equal to 1.875.
    qratios = []
    for key in sorted(groups, key=lambda k: (str(k[1]), str(k[0]))):
        q = None
        try:
            _m, _c, shown, _ctl, q = CS.grid_for(groups[key])
        except Exception:
            q = None
        if not q:
            continue
        scale, res = None, None
        for _n, _t, pay in groups[key]:
            cfg0 = pay.get("config") or {}
            scale = cfg0.get("uiParentEffectiveScale") or scale
            res = cfg0.get("resolution") or res
        if scale and res and "x" in str(res):
            w, h = (float(x) for x in str(res).split("x")[:2])
            # ★★★ THE CANDIDATE, TESTED not assumed:  q = 3 * aspect / (10 * uiScale)
            # UL-10 found 1/q_v = uiScale x 1.875 = uiScale x 15/8 at ONE resolution, and
            # 15/8 is exactly (10/3)/(16/9). ⟶ So the natural reading is that the quantum
            # is aspect-driven and the VERTICAL grid uses the NOMINAL 16:9 while the WIDTH
            # grid uses the SCREEN'S OWN aspect - which would explain the 0.0123% gap
            # between them without a second mechanism.
            qratios.append((res, float(scale), q,
                            3.0 * (w / h) / (10.0 * float(scale)),
                            3.0 * (16.0 / 9.0) / (10.0 * float(scale))))
        for _name, _task, pay in groups[key]:
            for fname, row in (pay.get("fonts") or {}).items():
                if not isinstance(row, dict) or fname not in resolved:
                    continue
                file, size = resolved[fname]
                a = adv.get(file)
                if not a:
                    continue
                strings = row.get("strings") or {}

                def quanta(s):
                    w = strings.get(s if s != "" else CS.EMPTY_KEY)
                    return None if w is None else round(w / q)

                samples = [(s, quanta(s)) for s in cal]
                samples = [(s, n) for s, n in samples if n is not None]
                if len(samples) < 3:
                    continue
                worst, k, c = CS.fit_constants(a, size, samples)
                held = []
                for s in spec:
                    n = quanta(s)
                    if n is not None:
                        held.append(abs(CS.base_quanta(a, k, s) + c - n))
                # ⚠ KEYED BY SCALE. Overwriting per font was the bug: one config's k
                # applied at every scale, and at one scale that was worse than the guess.
                e = fits.setdefault(fname, {"file": file, "size": size, "byScale": {}})
                e["byScale"][f"{float(scale):.4f}"] = {
                    "k": k, "c": c, "fitWorst": worst,
                    "heldWorst": max(held) if held else None,
                    "heldN": len(held)}

    if not fits:
        print("emit_text_metric: no font could be fitted (no derivable quantum?)")
        return 2

    # ★★ THE FORMULA UNDER TEST, printed per configuration before anything is emitted.
    # If it does not hold, the emitted file must not pretend it does.
    qerr = 0.0
    if qratios:
        print(f"\n  WIDTH QUANTUM UNDER TEST:  q = 3 * aspect / (10 * uiScale)")
        print(f"  {'resolution':<13}{'uiScale':>8}{'q measured':>16}{'q formula':>16}"
              f"{'rel':>10}   {'q_v (16:9)':>13}")
        for res, sc, qm, qf, qv in qratios:
            rel = abs(qm - qf) / qm
            qerr = max(qerr, rel)
            print(f"  {str(res):<13}{sc:>8.4f}{qm:>16.10f}{qf:>16.10f}{rel:>10.1e}"
                  f"   {qv:>13.10f}")
        print(f"  ⟶ worst relative error {qerr:.2e}"
              + ("   ★ the formula holds" if qerr < 1e-5
                 else "   ⚠⚠ IT DOES NOT HOLD - do not build on it"))

    files = sorted({v["file"] for v in fits.values()})
    lines = [
        "-- text_metric_data.lua - MACHINE-EMITTED by addons/tools/emit_text_metric.py.",
        "-- ⚠⚠ DO NOT EDIT. Re-run the tool; a hand edit is a number with no source.",
        "--",
        "-- Per-character advances in EMS, straight out of the client's own font files in",
        "-- locale-enUS.MPQ, plus a per-font-object linear correction (k, c) fitted on the",
        "-- sheet's CALIBRATION strings alone and scored on the SPECIMEN strings it never saw.",
        "--",
        "--     width_in_quanta = round(sum(adv[ch]) * k) + c        (check_sheet's model)",
        "--",
        "-- ⚠ `heldWorst` is the error in QUANTA on strings the fit never touched. It is the",
        "-- honest number; `fitWorst` only says the fitter converged.",
        "local M = {}",
        "",
        f"-- ★★★ THE WIDTH QUANTUM, COMPUTED:  q = 3 * (screenW/screenH) / (10 * uiScale)",
        f"-- Tested against {len(qratios)} measured configuration(s); worst relative error"
        f" {qerr:.2e}.",
        f"-- ⚠ The VERTICAL grid (UL-10) is the same formula on the NOMINAL 16:9 rather than",
        f"-- the screen's own aspect, which is the whole 0.0123% between them:",
        f"--     q_v = 3 * (16/9) / (10 * uiScale) = 8 / (15 * uiScale)   ->  1/q_v = uiScale * 1.875",
        f"M.qAspectK = 0.3          -- the 3/10",
        f"M.qNominalAspect = {16.0 / 9.0:.9f}",
        f"M.qWorstRelative = {qerr:.3e}",
        f"M.qN = {len(qratios)}",
        "",
        "M.adv = {",
    ]
    for f in files:
        a = adv.get(f) or {}
        pairs = []
        for ch in KEEP:
            if ch in a:
                pairs.append(f"[{ord(ch)}]={a[ch]:.6f}")
        lines.append(f"  [{lua_str(f)}] = {{ {', '.join(pairs)} }},")
        # ★ The fallback for anything outside KEEP - emitted, so the Lua side never
        # invents one and can say it used it.
        vals = [a[ch] for ch in KEEP if ch in a]
        mean = sum(vals) / len(vals) if vals else 0.5
        lines.append(f"  [{lua_str(f + '#mean')}] = {mean:.6f},")
    lines += ["}", "", "M.fonts = {"]
    for name in sorted(fits):
        v = fits[name]
        lines.append(f"  [{lua_str(name)}] = {{ file={lua_str(v['file'])},"
                     f" size={v['size']:.4f}, byScale = {{")
        for sc in sorted(v["byScale"]):
            b = v["byScale"][sc]
            held = "nil" if b["heldWorst"] is None else f"{b['heldWorst']:.0f}"
            lines.append(f"    [{lua_str(sc)}] = {{ k={b['k']:.9f}, c={b['c']:.0f},"
                         f" fitWorst={b['fitWorst']:.0f}, heldWorst={held},"
                         f" heldN={b['heldN']} }},")
        lines.append("  } },")
    lines += ["}", "", "return M", ""]

    OUT.write_text("\n".join(lines), encoding="utf-8")

    print(f"wrote {OUT.relative_to(REPO).as_posix()}")
    print(f"  {len(files)} font file(s), {len(KEEP)} chars each; {len(fits)} font object(s)")
    scales = sorted({s for v in fits.values() for s in v["byScale"]})
    print(f"\n  {'font object':<26}{'size':>5}   fitted at uiScale: "
          + " ".join(scales))
    print(f"  {'':<26}{'':>5}   worst HELD-OUT error in quanta per scale")
    for name in sorted(fits):
        v = fits[name]
        cells = []
        for s in scales:
            b = v["byScale"].get(s)
            cells.append("  -  " if not b else
                         f"{(b['heldWorst'] if b['heldWorst'] is not None else -1):>5.0f}")
        print(f"  {name:<26}{v['size']:>5.0f}   " + " ".join(cells))
    print(f"\n  ⚠ A uiScale with no column is NOT interpolated - the model returns nothing"
          f" and the caller falls back to the declared guess, marked.")
    print("\n  ⚠ `held` is the worst error in QUANTA on strings the fit never saw."
          " That is the number that matters.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
