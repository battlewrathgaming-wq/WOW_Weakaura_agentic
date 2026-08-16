r"""read_profile.py - slice the landed geom record. The READER half of §238.

★★★ WHY (Battlewrath, 2026-08-16): *"Can you make a stable test that captures
everything? And then a reader to filter to the slice of interest. That way we have a
profile as we develop."*

★★ THE CAPTURE IS STABLE; THIS IS WHERE THE QUESTIONS LIVE. `task_geom` does not learn a
new field every time we have a new question — it takes everything cheap and readable,
once, and every question after that is a slice of the same record. ⚠ Which is the
project's own law pointed at its own probe: *"the learner does not yet know what will
matter, so filtering at capture decides for them before they have had the run that would
have taught them."*

★ AND IT READS THE LANDED RECORD, not the client. `read_geom.py` parses SavedVariables
directly because it produces build constants and wants the freshest possible answer.
This is a PROFILE — provenance-stamped, comparable across captures, and readable with
the game closed.

    py addons/tools/read_profile.py                    the summary
    py addons/tools/read_profile.py --surface promoter one pane, every control
    py addons/tools/read_profile.py --kind readout     by DECLARED kind
    py addons/tools/read_profile.py --colors           every tone in use, and who uses it
    py addons/tools/read_profile.py --text             every string the UI draws
    py addons/tools/read_profile.py --unregistered     what nobody declared
    py addons/tools/read_profile.py --record <path>    an older capture
"""

import argparse
import glob
import io
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
RECORDS = ROOT + "/addons/landing/records"


def newest():
    hits = sorted(glob.glob(RECORDS + "/*__geom.json"))
    return hits[-1] if hits else None


def load(path):
    d = json.load(io.open(path, encoding="utf-8"))
    prov = d.get("_provenance", {})
    # ⚠ AN OPEN ENVELOPE IS SAID, NEVER HIDDEN. A capture the client had not finished
    # flushing is a real thing to know before reading numbers off it.
    #
    # ⚠⚠ AND THE VOCABULARY IS `complete` / `open` (`pull.py`:184), not `closed`. My
    # first cut warned on anything that was not "closed", so a GOOD capture printed a
    # warning — which is worse than no warning at all, because it is the fastest way to
    # teach someone to read past the one that matters.
    status = prov.get("envelope_status")
    if status and status != "complete":
        print("   ⚠ envelope status: %s - this capture may be partial" % status)
    return d.get("payload", {}) or {}, d.get("header", {}) or {}, prov


def surface_of(row):
    k = row.get("key") or ""
    return k.split(".")[0] if "." in k else (k or "?")


def rows_of(payload):
    return [r for r in (payload.get("ours") or []) if isinstance(r, dict)]


def fmt_rect(r):
    if r.get("w") is None:
        return ""
    return "%4d x %-4d" % (round(r.get("w") or 0), round(r.get("h") or 0))


def fmt_state(r):
    bits = []
    if r.get("shown") is False:
        bits.append("hidden")
    if r.get("enabled") is False:
        bits.append("disabled")
    if r.get("checked") is True:
        bits.append("checked")
    a = r.get("alpha")
    if a is not None and abs(a - 1.0) > 0.01:
        bits.append("alpha %.2f" % a)
    return " ".join(bits)


def hexcol(c):
    if not c or len(c) < 3:
        return None
    return "#%02x%02x%02x" % tuple(max(0, min(255, int((v or 0) * 255))) for v in c[:3])


def show_rows(rows, show_value=True):
    for r in sorted(rows, key=lambda x: (surface_of(x), x.get("key") or "")):
        key = r.get("key") or "?"
        line = "   %-26s %-12s %-11s" % (key, r.get("declaredKind") or
                                         (r.get("objectType") or ""), fmt_rect(r))
        extra = []
        st = fmt_state(r)
        if st:
            extra.append(st)
        col = hexcol(r.get("color"))
        if col:
            extra.append(col)
        if show_value and r.get("value") is not None:
            extra.append("= %s" % str(r["value"])[:28])
        t = r.get("text")
        if t:
            extra.append('"%s"' % str(t)[:34])
        print(line + ("  " + " · ".join(extra) if extra else ""))


def main():
    ap = argparse.ArgumentParser(description="slice the landed UI profile")
    ap.add_argument("--record")
    ap.add_argument("--surface")
    ap.add_argument("--kind")
    ap.add_argument("--colors", action="store_true")
    ap.add_argument("--text", action="store_true")
    ap.add_argument("--unregistered", action="store_true")
    a = ap.parse_args()

    path = a.record or newest()
    if not path or not os.path.exists(path):
        print("")
        print("   No geom record landed yet. Run `/coadump r geom` in game, /reload,")
        print("   then land it with the bench watcher.")
        print("")
        return 1

    payload, header, prov = load(path)
    rows = rows_of(payload)
    print("")
    print("   %s" % os.path.basename(path))
    print("   %s · %s · %d control row(s)" % (header.get("char", "?"),
                                              header.get("startedAt", "?"), len(rows)))
    print("   " + "-" * 70)

    # ⚠ A RECORD FROM BEFORE §238 HAS NO STATE HALF, and empty columns read as "nothing
    # to see" rather than "not captured". Said once, at the top, so every slice below is
    # read knowing which it is.
    if rows and not any(r.get("declaredKind") for r in rows):
        print("   ⚠ This capture predates §238 - no declaredKind, value, colour, alpha")
        print("     or text on our side. Re-run `/coadump r geom` for the full profile.")
        print("")

    if a.colors:
        # ★ EVERY TONE, AND WHO WEARS IT. The consequence register needs a fourth colour
        # and a colour cannot be judged alone — this is the palette on one page.
        #
        # ⚠⚠ TWO SOURCES, AND THE SECOND IS THE REAL ONE. `GetTextColor` returns the
        # FontString's BASE colour, which is whatever its template set. Almost every tone
        # this UI actually uses is an INLINE ESCAPE CODE inside the text — `|cffffd100`
        # and friends — so reading only the base would have reported a palette of three
        # greys and missed all eight.
        base, inline = {}, {}
        for r in rows:
            c = hexcol(r.get("color"))
            if c:
                base.setdefault(c, []).append(r.get("key") or "?")
            for m in re.finditer(r"\|c[fF][fF]([0-9a-fA-F]{6})", str(r.get("text") or "")):
                inline.setdefault("#" + m.group(1).lower(), []).append(r.get("key") or "?")
        if not base and not inline:
            print("   No colours captured. ⚠ `color` arrived in §238 - an older record")
            print("   predates it, so re-run the capture rather than reading a gap as none.")
        if inline:
            print("   INLINE (the tones the UI actually paints with)")
            for c in sorted(inline, key=lambda k: -len(inline[k])):
                print("     %s  %2d   %s" % (c, len(inline[c]), ", ".join(inline[c][:4])))
        if base:
            print("")
            print("   BASE (the FontString's own colour, from its template)")
            for c in sorted(base, key=lambda k: -len(base[k])):
                print("     %s  %2d   %s" % (c, len(base[c]), ", ".join(base[c][:4])))
        print("")
        return 0

    if a.text:
        for r in sorted(rows, key=lambda x: x.get("key") or ""):
            if r.get("text"):
                print('   %-26s "%s"' % (r.get("key") or "?", r["text"]))
        print("")
        return 0

    if a.unregistered:
        hits = [r for r in rows if r.get("registered") is False]
        if not hits:
            print("   Every widget in every walked pane is registered.")
        show_rows(hits, show_value=False)
        print("")
        return 0

    if a.surface:
        hits = [r for r in rows if surface_of(r) == a.surface.strip().lower()]
        if not hits:
            print("   No rows for surface '%s'. Known: %s" % (
                a.surface, ", ".join(sorted(set(surface_of(r) for r in rows)))))
        show_rows(hits)
        print("")
        return 0

    if a.kind:
        hits = [r for r in rows if (r.get("declaredKind") or "") == a.kind.strip()]
        if not hits:
            kinds = sorted(set(r.get("declaredKind") or "" for r in rows) - {""})
            print("   No rows of kind '%s'. Known: %s" % (a.kind, ", ".join(kinds)))
        show_rows(hits)
        print("")
        return 0

    # ★ The default is a SHAPE, not a dump — per surface, what is there and what is
    # missing, so the next flag you reach for is obvious.
    by = {}
    for r in rows:
        by.setdefault(surface_of(r), []).append(r)
    for s in sorted(by):
        rs = by[s]
        unreg = sum(1 for r in rs if r.get("registered") is False)
        kinds = sorted(set(r.get("declaredKind") or "" for r in rs) - {""})
        print("   %-14s %3d row(s)%s   %s" % (
            s, len(rs), ("  ⚠ %d unregistered" % unreg) if unreg else "",
            " ".join(kinds)))
    print("")
    print("   --surface <name> · --kind <k> · --colors · --text · --unregistered")
    print("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
