"""check_escapes.py - catch the backslash Lua 5.1 EATS WITHOUT COMPLAINING.

★ WHY THIS EXISTS. `"Interface\\DialogFrame\\UI-DialogBox-Background"` written with
ONE backslash per separator is not a syntax error on 5.1. The lexer's default
branch for an unrecognised escape saves the escaped CHARACTER and drops the
backslash, so the literal silently becomes:

    InterfaceDialogFrameUI-DialogBox-Background

- which is a texture path that matches nothing. `SetBackdrop` accepts it, returns
no error, and the frame simply has no background and no border. Verified against
the bench interpreter, not from memory:

    single-backslash source -> [InterfaceDialogFrameUI-DialogBox-Background]  len 43
    double-backslash source -> [Interface\\DialogFrame\\UI-DialogBox-Background]  len 45

★ AND IT SHIPPED. COA_DungeonRun's readout panel carried the broken form from
§69 through a commit, a deploy and live authoring sessions. Nothing caught it,
because there was nothing that COULD: it parses, it loads, the smokes exercise
the logic rather than the strings, and the failure is a panel that is merely
*invisible* rather than one that errors. It is the exact defect shape the bench
keeps naming - a hole that is quiet - so it gets an instrument instead of
vigilance.

⚠ THIS IS A DEFECT CHECK, NOT A CENSUS. The addon census is a file you READ; it
describes the surface. This one FAILS - exit 1 with the file, the line and the
offending literal - because a broken texture path is wrong rather than merely
worth knowing.

Scope is deploy.py's MANIFEST, the same one authority the census uses. Reference
addons under `refs_*` are deliberately out of scope: SignalFire has seven of
these in `BronzeLFG.lua` and they are not ours to fix.

Usage:
    py addons\\tools\\check_escapes.py
    py addons\\tools\\check_escapes.py --addon COA_DungeonRun
"""
import argparse
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ADDONS = HERE.parent

sys.path.insert(0, str(ADDONS))
from deploy import MANIFEST                      # noqa: E402 - the one authority

# Lua 5.1 lexer, llex.c read_string: the named escapes, the line continuation,
# the quote/backslash literals, and \ddd. Everything else falls to `default`,
# which saves the character and throws the backslash away.
#
# ⚠ \x IS NOT ON THIS LIST ON PURPOSE. Hex escapes arrived in 5.2; on 5.1
# "\x41" is the two characters x4 followed by 1, which is precisely the kind of
# quiet wrong this tool is for.
VALID = set("abfnrtv\\\"'\n") | set("0123456789")


def bad_escapes(text):
    """(line, col, escape, context) for every backslash 5.1 would drop.

    A real scan rather than a regex: escapes are only live inside SHORT strings,
    so long strings ([[...]]) and both comment forms have to be skipped or the
    tool reports every path we merely DOCUMENT. This file's own docstring is the
    first thing that would trip it.
    """
    out = []
    i, n, line = 0, len(text), 1

    def long_bracket(j):
        """Length of a [==[ opener at j, or 0. Returns the '=' count too."""
        if text[j] != "[":
            return 0, 0
        k = j + 1
        eq = 0
        while k < n and text[k] == "=":
            eq += 1
            k += 1
        if k < n and text[k] == "[":
            return k - j + 1, eq
        return 0, 0

    while i < n:
        c = text[i]

        if c == "\n":
            line += 1
            i += 1
            continue

        # comments - line and long. Checked before long strings so --[[ wins.
        if c == "-" and text[i:i + 2] == "--":
            span, eq = long_bracket(i + 2)
            if span:
                close = "]" + "=" * eq + "]"
                end = text.find(close, i + 2 + span)
                end = n if end < 0 else end + len(close)
                line += text.count("\n", i, end)
                i = end
            else:
                end = text.find("\n", i)
                i = n if end < 0 else end
            continue

        # long strings - no escape processing at all inside them
        span, eq = long_bracket(i)
        if span:
            close = "]" + "=" * eq + "]"
            end = text.find(close, i + span)
            end = n if end < 0 else end + len(close)
            line += text.count("\n", i, end)
            i = end
            continue

        # short strings - the only place an escape is live
        if c in "\"'":
            quote, start_line = c, line
            j = i + 1
            while j < n:
                d = text[j]
                if d == "\\":
                    nxt = text[j + 1] if j + 1 < n else ""
                    if nxt not in VALID:
                        col = j - text.rfind("\n", 0, j)
                        ctx = text[i:text.find("\n", i) if text.find("\n", i) > 0 else n]
                        out.append((line, col, "\\" + nxt, ctx.strip()))
                    if nxt == "\n":
                        line += 1
                    j += 2
                    continue
                if d == quote:
                    j += 1
                    break
                if d == "\n":            # unterminated; let Lua complain, not us
                    line += 1
                    j += 1
                    break
                j += 1
            i = j
            continue

        i += 1

    return out


# ★ THE TOOL PROVES ITSELF. A checker that has only ever reported CLEAN is
# indistinguishable from one that returns an empty list, and this bench has been
# bitten by exactly that shape - a guard whose fixture could not reach its own
# failure case. Every skip branch below is a way the tool could go quiet, so each
# one gets a case that would fire if it were wrong in either direction.
SELFTEST = [
    # (source, expected finding count, what it proves)
    (r'local s = "Interface\DialogFrame\X"', 2, "the shipped defect, both separators"),
    (r'local s = "Interface\\DialogFrame\\X"', 0, "the correct form is silent"),
    (r'-- bgFile = "Interface\DialogFrame\X"', 0, "line comments document freely"),
    ('--[[ "Interface\\Foo" ]]', 0, "long comments too"),
    ('--[==[ "Interface\\Foo" ]==]', 0, "...at any bracket level"),
    (r'local s = [[Interface\Foo]]', 0, "long strings have no escapes at all"),
    (r'local s = "a\tb\nc\\d\065e"', 0, "every valid 5.1 escape passes"),
    (r'local s = "\x41"', 1, "5.1 has NO hex escape - \\x is a dropped backslash"),
    (r'local s = "say \"hi\" then \Q"', 1, "escaped quotes do not end the string"),
    ('local a = "ok"\nlocal b = "bad\\Q"', 1, "reported on line 2, not line 1"),
    (r"local s = 'Interface\Foo'", 1, "single-quoted strings are strings too"),
]


def selftest():
    bad = 0
    for src, want, why in SELFTEST:
        got = bad_escapes(src)
        ok = len(got) == want
        if not ok:
            bad += 1
        print(f"  {'ok  ' if ok else 'FAIL'}  {why}"
              + ("" if ok else f"   (wanted {want}, got {len(got)}: {got})"))
    # the line-number claim, checked rather than asserted in a comment
    ln = bad_escapes('local a = "ok"\nlocal b = "bad\\Q"')[0][0]
    if ln != 2:
        print(f"  FAIL  line number is {ln}, expected 2")
        bad += 1
    else:
        print("  ok    line number lands on the offending line")
    print(f"\n{'SELFTEST FAILED' if bad else 'selftest OK'} - "
          f"{len(SELFTEST) + 1} case(s), {bad} failure(s)")
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--addon", help="check only this resident")
    ap.add_argument("--selftest", action="store_true",
                    help="prove the checker bites; scan nothing")
    a = ap.parse_args()

    if a.selftest:
        return selftest()

    if a.addon and a.addon not in MANIFEST:
        sys.exit(f"'{a.addon}' is not a resident. Residents: {', '.join(MANIFEST)}")

    names = [a.addon] if a.addon else list(MANIFEST)
    findings, scanned = [], 0

    for name in names:
        folder = ADDONS / name
        if not folder.is_dir():
            continue
        for lua in sorted(folder.glob("*.lua")):
            scanned += 1
            for ln, col, esc, ctx in bad_escapes(
                    lua.read_text(encoding="utf-8", errors="replace")):
                findings.append((f"{name}/{lua.name}", ln, col, esc, ctx))

    if not findings:
        print(f"escapes OK - {scanned} file(s), no dropped backslashes")
        return 0

    print(f"DROPPED BACKSLASHES - {len(findings)} in {scanned} file(s):\n")
    for f, ln, col, esc, ctx in findings:
        print(f"  {f}:{ln}:{col}  '{esc}' is not a Lua 5.1 escape - the backslash is DISCARDED")
        print(f"      {ctx[:96]}")
    print("\n  Fix: double every separator - \"Interface\\\\Path\\\\File\".")
    return 1


if __name__ == "__main__":
    sys.exit(main())
