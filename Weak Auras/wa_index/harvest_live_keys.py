"""
harvest_live_keys.py - derive WHICH trigger keys the handler actually READS (live) vs stores-but-never-reads (residue).

Born from a live catch (2026-07-14): `spellIds` word-matched the gate (a real WA word, stored on real triggers) but the
aura2 handler never reads it - only the legacy converter does. Import lands clean, matching is silently dead. The
liveness fact exists ONLY in the handler source, so: read the SOURCE, attribute every `trigger.<key>` access to its
enclosing top-level function, mark the convert/migration functions' spans as not-live context. A key is LIVE if any
access falls outside those spans.

Emits the known-good table -> engine/Fact_basis/maps/live_keys.json (maps = settled facts machines consult).
Then DIFFS against the harvested sheet (engine/Fact_basis/sheets/trigger/<type>.json) so the two artifacts audit each
other - disagreements are REPORTED, never silently resolved. Re-run on client patch; the git diff is the change control.

  py harvest_live_keys.py           -> harvest every configured type + write the map + print the sheet diff
"""
import json
import os
import re
import time

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
CLIENT_WA = r"F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\WeakAuras"
SHEETS = os.path.join(_WA, "engine", "Fact_basis", "sheets", "trigger")
OUT = os.path.join(_WA, "engine", "Fact_basis", "maps", "live_keys.json")

# per trigger type: the handler file + the convert/migration functions whose reads are NOT live config.
TYPES = {
    "aura2": {"file": "BuffTrigger2.lua",
              "convert_funcs": ("CanConvertBuffTrigger2", "ConvertBuffTrigger2")},
}

_FUNC = re.compile(r"^(?:local\s+)?function\s+([\w.:]+)")        # top-level function declarations (col 0)
_ACCESS = re.compile(r"\btrigger\.(\w+)")                        # trigger.<key> (won't match triggerInfo.<key>)


def harvest(ttype, cfg):
    path = os.path.join(CLIENT_WA, cfg["file"])
    lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    funcs = [(i + 1, m.group(1)) for i, ln in enumerate(lines) if (m := _FUNC.match(ln))]
    spans = []                                                   # (start, end, name) - decl to next top-level decl
    for j, (start, name) in enumerate(funcs):
        end = funcs[j + 1][0] - 1 if j + 1 < len(funcs) else len(lines)
        spans.append((start, end, name))

    def enclosing(n):
        for start, end, name in spans:
            if start <= n <= end:
                return name
        return "(file scope)"

    keys = {}
    for i, ln in enumerate(lines, 1):
        for m in _ACCESS.finditer(ln):
            key, fn = m.group(1), enclosing(i)
            in_convert = any(fn.endswith(c) for c in cfg["convert_funcs"])
            rec = keys.setdefault(key, {"n_live": 0, "n_convert": 0, "via": None, "via_convert": None})
            if in_convert:
                rec["n_convert"] += 1
                rec["via_convert"] = rec["via_convert"] or "%s:%d (%s)" % (cfg["file"], i, fn)
            else:
                rec["n_live"] += 1
                rec["via"] = rec["via"] or "%s:%d (%s)" % (cfg["file"], i, fn)
    for rec in keys.values():
        rec["live"] = rec["n_live"] > 0
    return keys, path


def sheet_keys(ttype):
    p = os.path.join(SHEETS, "%s.json" % ttype)
    if not os.path.exists(p):
        return None
    sheet = json.load(open(p, encoding="utf-8"))
    out = set()
    for ev in sheet.get("events", []):
        for i in ev.get("options", {}).get("inputs", []):
            out.add(i["name"])
    return out


def main():
    table = {"_meta": {"what": "key LIVENESS per trigger type: read by the handler (live) vs stored-but-only-converter "
                               "(residue). Harvested from the fork's handler source; the gate blocks residue declares.",
                       "source_root": CLIENT_WA, "harvested": time.strftime("%Y-%m-%d"),
                       "derivation": "trigger.<key> accesses attributed to enclosing top-level function; "
                                     "convert/migration spans = not-live context"}}
    for ttype, cfg in TYPES.items():
        keys, path = harvest(ttype, cfg)
        table[ttype] = {"handler": cfg["file"], "convert_funcs": list(cfg["convert_funcs"]), "keys": keys}
        live = sorted(k for k, r in keys.items() if r["live"])
        residue = sorted(k for k, r in keys.items() if not r["live"])
        print("== %s  (%s: %d keys accessed)" % (ttype, cfg["file"], len(keys)))
        print("   live    (%d): %s" % (len(live), ", ".join(live)))
        print("   residue (%d): %s" % (len(residue), ", ".join("%s [%s]" % (k, keys[k]["via_convert"]) for k in residue)))
        sk = sheet_keys(ttype)
        if sk is None:
            print("   sheet diff: NO SHEET for %s - nothing to audit against" % ttype)
        else:
            unsheeted = sorted(set(keys) - sk)                   # handler reads it, sheet doesn't name it -> sheet gap
            unread = sorted(sk - set(keys))                      # sheet names it, handler never touches it (options-half
            print("   sheet diff: %d handler-read keys NOT on the sheet -> sheet gap: %s"
                  % (len(unsheeted), ", ".join(unsheeted) or "(none)"))
            print("               %d sheet keys never accessed by the handler (options-half/UI names - expected): %s"
                  % (len(unread), ", ".join(unread[:12]) + ("..." if len(unread) > 12 else "")))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(table, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("\nwrote %s" % os.path.relpath(OUT, _WA))


if __name__ == "__main__":
    main()
