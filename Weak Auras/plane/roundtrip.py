"""
roundtrip.py - the plane_v2 anchor test. Drives a MINIMAL, source-authored aura (the reasoned delta only)
through the P11 body and asserts it is reimport-stable:

    minimal  --canon-->  A  --encode-->  string  --decode-->  B  --canon-->  B2   ;   diff(A, B2) == clean

canon = WA's own acceptor headless (wa_lua_verify/canon.lua). "clean" here means reimport-STABLE under the
fast proxy - NOT the ground-truth gate (that stays the live client: import the string, re-export, diff).
This is the red/green anchor the rest of the pipeline is built to turn green. No corpus in the loop.

  py roundtrip.py
"""
import json
import os
import subprocess
import sys
import tempfile

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)                 # Weak Auras/
_ROOT = os.path.dirname(_WA)
sys.path.insert(0, _WA)
sys.path.insert(0, _THIS)
import weakaura_codec as wc
import diff as diffmod

LUA = os.path.join(_ROOT, ".tools", "lua51", "lua5.1.exe")
CANON = os.path.join(_WA, "wa_lua_verify", "canon.lua")


def _to_lua(o):
    """python value -> Lua literal (canon reads `return <literal>`)."""
    if isinstance(o, bool):
        return "true" if o else "false"
    if o is None:
        return "nil"
    if isinstance(o, (int, float)):
        return repr(o)
    if isinstance(o, str):
        return '"' + o.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r") + '"'
    if isinstance(o, (list, tuple)):
        return "{" + ",".join(_to_lua(v) for v in o) + "}"
    if isinstance(o, dict):
        parts = []
        for k, v in o.items():
            if v is None:
                continue
            key = "[%d]" % k if isinstance(k, int) else "[%s]" % _to_lua(str(k))
            parts.append("%s=%s" % (key, _to_lua(v)))
        return "{" + ",".join(parts) + "}"
    raise TypeError("cannot serialise %r" % type(o))


def canon(aura):
    """run WA's acceptor on an aura table -> the completed table."""
    fd, path = tempfile.mkstemp(suffix=".lua")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write("return " + _to_lua(aura) + "\n")
        p = subprocess.run([LUA, CANON, path], capture_output=True, text=True)
        if p.returncode != 0:
            sys.exit("canon failed:\n" + p.stderr[:600])
        return json.loads(p.stdout)
    finally:
        os.unlink(path)


# ------------------------------------------------------------------ the source-authored MINIMAL
# reasoned delta ONLY: a cooldown-button icon for one spell. Everything else, WA completes.
MINIMAL = {
    "id": "CoA Corpse Explosion",
    "uid": "coaCorpExpl0001",
    "internalVersion": 86,               # current (WeakAuras.lua:4) -> Modernize no-ops
    "regionType": "icon",
    "triggers": {
        1: {
            "trigger": {"type": "spell", "event": "Cooldown Progress (Spell)",
                        "spellName": 533236, "use_spellName": True, "genericShowOn": "showAlways"},
            "untrigger": {},
        },
    },
    "load": {"class": {"single": "NECROMANCER"}},
}


def main():
    A = canon(MINIMAL)                                   # WA completes our minimal
    s = wc.encode_import_string(A)                       # export
    B = wc.decode_import_string(s)                       # reimport (decode)
    B2 = canon(B)                                        # WA completes the reimport
    d = diffmod.deep_diff(A, B2)                         # reimport-stable?
    diffs = d if isinstance(d, list) else ([] if not d else [d])
    print("minimal authored : %d fields" % len(MINIMAL))
    print("WA-completed (A)  : %d fields" % len(A))
    print("import string     : %d chars" % len(s))
    if diffs:
        print("\nRED - reimport diff (%d):" % len(diffs))
        for line in diffs[:40]:
            print("   ", line)
        sys.exit(1)
    print("\nGREEN - reimport-stable headless. (Ground-truth gate remains the live client.)")


if __name__ == "__main__":
    main()
