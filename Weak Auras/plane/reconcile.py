"""
reconcile.py - the fill/canon -> codec GATE (the "controlled bounce").

canon (WA's acceptor) hands its result back as JSON, and JSON stringifies integer
table keys. That is harmless for a PURE array (JSON keeps it a list) but corrupts a
MIXED table - one with both an integer array part AND string keys. The only mixed
table in a WA aura is `data.triggers`: integer 1..N (the triggers) PLUS string keys
`disjunctive` / `activeTriggerMode` / `customTriggerLogic` (the combination). After
canon it comes back as {"1":..,"2":..,"disjunctive":..} - the "1","2" are now strings,
the codec's _split_table can't see the array run, and it encodes them as string map
keys. Real WA then reads `#data.triggers == 0` and RESETS the aura to one default
trigger. (Reproduced 2026-07-13; matched a live malformation.)

This module is the single, auditable place that reconciles those shape mismatches
between what canon returns and what the codec expects - so `fill` stays dumb and the
codec stays pure (it was never wrong; it was handed a bad shape). It is TARGETED, not
a blanket normaliser: it only touches the array keys of `triggers` tables, never
arbitrary string-digit keys elsewhere (which could be a genuine string-keyed map).
New fill/canon->codec mismatches get new TARGETED rules here - one home, no scatter.

  bounce(aura) -> codec-ready aura     # canon + reconcile; use this instead of bare canon
  reconcile(aura) -> aura              # the pure shape-fix (idempotent)
  canon(aura) -> aura                  # raw WA acceptor (re-exported)
"""
import json
import os
import subprocess
import sys
import tempfile

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)                 # Weak Auras/
_ROOT = os.path.dirname(_WA)
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
    """run WA's acceptor on an aura table -> the completed table (JSON-shaped)."""
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


def _restore_array_keys(tab):
    """One mixed table: convert its contiguous "1".."N" string keys back to int (the
    array part JSON stringified); leave every other key (disjunctive, ...) untouched.
    Idempotent - already-int keys are found by the run and pass through unchanged."""
    if not isinstance(tab, dict):
        return tab
    n = 1
    while str(n) in tab or n in tab:            # length of the contiguous 1.. run
        n += 1
    run_end = n - 1
    out = {}
    for k, v in tab.items():
        if isinstance(k, str) and k.isdigit() and 1 <= int(k) <= run_end:
            out[int(k)] = v
        else:
            out[k] = v
    return out


def reconcile(aura):
    """The fill/canon -> codec gate. TARGETED: restores the array keys of every
    `triggers` table (the sole mixed table), recursing so group children are covered.
    Everything else passes through verbatim - no blanket normalisation."""
    if isinstance(aura, dict):
        out = {}
        for k, v in aura.items():
            v = reconcile(v)
            if k == "triggers" and isinstance(v, dict):
                v = _restore_array_keys(v)
            out[k] = v
        return out
    if isinstance(aura, list):
        return [reconcile(x) for x in aura]
    return aura


def bounce(aura):
    """The controlled bounce: run a filled aura through WA's acceptor, then reconcile
    to a codec-ready shape. Use this everywhere instead of bare canon so no encode or
    diff ever sees canon's JSON-stringified keys.  fill -> bounce -> codec."""
    return reconcile(canon(aura))
