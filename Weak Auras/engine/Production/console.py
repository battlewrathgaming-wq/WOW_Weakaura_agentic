"""
console.py - the Production console. Spawn it, drive it - NO commands to type.

On spawn it STAGES automatically (checks _authored -> gate -> Docket_stage) and drops you straight into the PICKER
we agreed: a checkbox list of the staged PID packs. Drive it:
  up / down   move the > cursor
  SPACE       on a pack: toggle [ ] <-> [x]   ·   on [ Run selected ]: run the checked packs into import strings
  ENTER       inspect the focused pack (decode its output group, or list its staged dockets)
  r           re-stage from _authored          q / Esc   quit
Windows key input (msvcrt). Launch: menu [6], console.bat, or `py console.py`.
"""
import glob
import json
import os
import subprocess
import sys
try:
    import msvcrt
except ImportError:
    msvcrt = None

_THIS = os.path.dirname(os.path.abspath(__file__))
STAGE = os.path.join(_THIS, "Docket_stage")
COMPLETE = os.path.join(_THIS, "Docket_complete")
sys.path.insert(0, os.path.join(_THIS, "..", "..", "plane"))
sys.path.insert(0, os.path.join(_THIS, "..", ".."))
import weakaura_codec as wc                                      # to decode a produced group in `inspect`


def _sh(args, quiet=False):
    subprocess.run(["py"] + args, cwd=_THIS, capture_output=quiet)


def _pids():
    return sorted(d for d in os.listdir(STAGE) if os.path.isdir(os.path.join(STAGE, d))) if os.path.isdir(STAGE) else []


def _getkey():
    ch = msvcrt.getch()
    if ch in (b"\x00", b"\xe0"):                                 # arrow / function-key prefix
        return {b"H": "up", b"P": "down"}.get(msvcrt.getch())
    return {b" ": "space", b"\r": "enter", b"q": "quit", b"\x1b": "quit", b"r": "restage"}.get(ch)


def _inspect(pid):
    os.system("cls")
    txt = os.path.join(COMPLETE, pid + ".txt")
    if os.path.exists(txt):                                      # completed -> DECODE, prove it's a real aura
        s = open(txt, encoding="utf-8").read().strip()
        try:
            d, ch = wc.decode_group_import_string(s)
            print("%s   OUTPUT (%d chars) - decoded:\n" % (pid, len(s)))
            print("   group : %s   [%s]" % (d.get("id"), d.get("regionType")))
            for c in ch:
                print("   child : %s   [%s]" % (c.get("id"), c.get("regionType")))
            print("\n   import string: Docket_complete\\%s.txt   (paste into WA)" % pid)
        except Exception as e:
            print("%s: could not decode (%s)" % (pid, e))
    else:                                                        # still staged -> list the pack's dockets
        print("%s   STAGED dockets:\n" % pid)
        for f in sorted(glob.glob(os.path.join(STAGE, pid, "*.docket.json"))):
            d = json.load(open(f, encoding="utf-8"))
            print("   %-26s %s   [%s]" % (os.path.basename(f), d.get("id"), d.get("regionType")))
    print("\n(press any key)")
    msvcrt.getch()


def _run(pids):
    os.system("cls")
    print("Running %d pack(s): %s\n" % (len(pids), ", ".join(pids)))
    _sh(["pickup.py"] + pids)                                    # visible: the PACKED lines
    _sh(["stage.py"], quiet=True)                               # silent: repopulate so the packs stay listed (now 'done')
    print("\n(press any key to return)")
    msvcrt.getch()


def picker():
    checked, focus, msg = set(), 0, ""
    while True:
        pids = _pids()
        rows = pids + [None]                                    # None = the [ Run selected ] action row
        focus = max(0, min(focus, len(rows) - 1))
        os.system("cls")
        print("=== COA Production ===   pick packs to run\n")
        print("  up/down move   -   SPACE toggle / run   -   ENTER inspect   -   r re-stage   -   q quit\n")
        if not pids:
            print("  (nothing staged - is _authored empty?)\n")
        for i, pid in enumerate(rows):
            cur = ">" if i == focus else " "
            if pid is None:
                print("\n %s   [ Run selected (%d) ]" % (cur, len(checked & set(pids))))
            else:
                n = len(glob.glob(os.path.join(STAGE, pid, "*.docket.json")))
                done = "   (done)" if os.path.exists(os.path.join(COMPLETE, pid + ".txt")) else ""
                print(" %s [%s] %-24s %d docket(s)%s" % (cur, "x" if pid in checked else " ", pid, n, done))
        if msg:
            print("\n  " + msg)
        k = _getkey()
        if k == "quit":
            return
        elif k == "up":
            focus = (focus - 1) % len(rows)
        elif k == "down":
            focus = (focus + 1) % len(rows)
        elif k == "restage":
            _sh(["stage.py"], quiet=True); msg = "re-staged from _authored"
        elif k in ("space", "enter"):
            pid = rows[focus]
            if pid is None:                                     # the Run action
                sel = [p for p in pids if p in checked]
                if sel:
                    _run(sel); checked.clear(); msg = "ran: " + ", ".join(sel)
            elif k == "enter":
                _inspect(pid)
            else:                                               # SPACE on a pack = toggle
                checked.symmetric_difference_update({pid})


def main():
    if msvcrt is None:
        print("This console needs a Windows terminal."); return
    _sh(["stage.py"], quiet=True)                               # CHECK ON SPAWN: _authored -> gate -> Docket_stage
    picker()


if __name__ == "__main__":
    main()
