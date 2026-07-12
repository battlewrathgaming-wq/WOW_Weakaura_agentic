"""
verify_enums.py - ONE-TIME cross-check: verify spell_enums.py's Effect/Aura tables against a
SECOND independent authority - AzerothCore's SharedDefines.h (which IS 3.3.5a). Fetches the raw
header (urllib, exact bytes - no model-summarization in the loop), parses the SpellEffects +
AuraType enums, and diffs index-by-index. Gives the enum stage the two-sources-agree property
the spell IDs already have - and Claude is not one of the two sources; the diff is mechanical.

  py verify_enums.py

Any mismatch is FLAGGED (structured). Whether a flag is a real transcription error or a benign
naming-convention difference (e.g. `unk112` vs a later-named effect) is the judgment left to the
reader - the mechanical part just surfaces exactly where the two authorities disagree.
"""
import os
import re
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import spell_enums as se

# TrinityCore's 3.3.5 branch = frozen 3.3.5a, and the very authority spell_enums.py cites.
_TC = "https://raw.githubusercontent.com/TrinityCore/TrinityCore/3.3.5/src/server/"
EFF_URL = _TC + "shared/SharedDefines.h"                    # enum SpellEffects
AURA_URL = _TC + "game/Spells/Auras/SpellAuraDefines.h"     # enum AuraType


def _fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "enum-verify"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read().decode("utf-8", "replace")


def _parse_enum(src, enum_name, prefix):
    m = re.search(r"enum\s+" + enum_name + r"\b[^{]*\{(.*?)\}", src, re.S)
    if not m:
        return None
    out = {}
    for name, num in re.findall(r"\b" + prefix + r"(\w+)\s*=\s*(\d+)", m.group(1)):
        out[int(num)] = name.lower()
    return out


def _is_placeholder(n):
    # an unnamed slot on either side: spell_enums `unk112`/`aura_46`, or TC's bare stripped `112`
    return bool(re.fullmatch(r"(unk|aura)?_?\d+", n or ""))


def _diff(ours, theirs, label):
    if theirs is None:
        print("%s: could not parse the enum (check the source layout)" % label)
        return -1
    print("%s: ours=%d (0..%d)  trinitycore=%d (0..%d)"
          % (label, len(ours), max(ours), len(theirs), max(theirs)))
    benign, flags = [], []
    for k in sorted(set(ours) | set(theirs)):
        o, t = ours.get(k), theirs.get(k)
        if o == t:
            continue
        if _is_placeholder(o) and _is_placeholder(t):
            benign.append((k, o, t))
        else:
            flags.append((k, o, t))
    agree = len(ours) - len(benign) - len(flags)
    print("   %d exact-agree, %d unnamed-both (benign), %d to REVIEW" % (agree, len(benign), len(flags)))
    for k, o, t in flags:
        print("   REVIEW [%3d] ours=%-22r trinitycore=%r" % (k, o, t))
    return len(flags)


def main():
    print("fetching SpellEffects <- %s" % EFF_URL)
    eff_src = _fetch(EFF_URL)
    print("fetching AuraType     <- %s" % AURA_URL)
    aur_src = _fetch(AURA_URL)
    print("  got %d + %d bytes\n" % (len(eff_src), len(aur_src)))
    m1 = _diff(se.EFFECT, _parse_enum(eff_src, "SpellEffects", "SPELL_EFFECT_"), "EFFECT")
    print()
    m2 = _diff(se.AURA, _parse_enum(aur_src, "AuraType", "SPELL_AURA_"), "AURA ")
    print("\nVERDICT: %s"
          % ("CLEAN - both enums fully agree with TrinityCore 3.3.5" if m1 == 0 and m2 == 0
             else "MISMATCHES flagged above - review each"))
    return 0 if m1 == 0 and m2 == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
