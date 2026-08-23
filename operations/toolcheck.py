# -*- coding: utf-8 -*-
r"""toolcheck.py - the ENVIRONMENT against its known-good state.

    py operations/toolcheck.py             verify
    py operations/toolcheck.py --restore   rewrite .claude/settings.json from the declaration

★★★ WHY THIS EXISTS, and it is NOT backup. Three of the four config files are TRACKED, so git
restores them and would do it better than any script here. The gap is different and it is the one
this project keeps finding:

    ⚠⚠ A MALFORMED settings.json SILENTLY DISABLES **EVERY SETTING IN THAT FILE** - the refusal
    hook AND the permission bounds - WITH NO ERROR. One stray comma and the environment is wide
    open while everything reports normal.

★ That is a GREEN WITH NOTHING BEHIND IT, at the environment layer. This project has now recorded
FIVE guards that went inert while printing green (§457 · §458 · §465 · §472 · §511); a config file
that turns itself off is the same shape one layer out, and nothing was watching for it.

★★ THE KNOWN-GOOD STATE IS DECLARED HERE, NOT SNAPSHOTTED. A snapshot is an opaque blob nobody
reads; a declaration is greppable, inspectable, and reviewable in a diff - **L18, load-bearing ⟹
sourceable**, applied to the environment. `--restore` writes the declaration back out; it is one
source, not a second copy.

⚠ WHAT IT DELIBERATELY DOES NOT COVER: `.claude/settings.local.json` is UNTRACKED and holds
personal permission accretion - grants earned by use on this machine. It is not a thing to restore
to a "default", and capturing it into the repo would defeat the gitignore that keeps it personal.
⟶ This checks that it PARSES (a malformed one disables its allows silently, same fault) and stops
there.

⚠ `--restore` edits `.claude/settings.json`, which PROTOCOL 1c puts behind `ask`. That prompt is
correct and deliberate: a restore is a decision, not a reflex.
"""

import io
import json
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
SETTINGS = os.path.join(REPO, ".claude", "settings.json")
LOCAL = os.path.join(REPO, ".claude", "settings.local.json")
HOOKDIR = os.path.join(REPO, ".claude", "hooks")

# ─────────────────────────────────────────────────────────────────────────────
# THE DECLARATION - the known-good state of the project config, in one place.
# ⚠ Changing this is changing the environment. It belongs in the same commit as the change
# and in operations/TOOL_CONFIG_TRAIL.md.
# ─────────────────────────────────────────────────────────────────────────────
KNOWN_GOOD = {
    "permissions": {
        "deny": [
            "Edit(.claude/settings.local.json)",
            "Write(.claude/settings.local.json)",
        ],
        "ask": [
            "Edit(.claude/settings.json)",
            "Write(.claude/settings.json)",
            "Edit(.claude/hooks/**)",
            "Write(.claude/hooks/**)",
        ],
    },
    "hooks": {
        "PreToolUse": [
            {
                "matcher": "Bash",
                "hooks": [
                    {
                        "type": "command",
                        "command": "node .claude/hooks/no-shell-python.js",
                        "timeout": 10,
                        "statusMessage": "checking the instrument",
                    }
                ],
            },
            {
                "matcher": "Write",
                "hooks": [
                    {
                        "type": "command",
                        "command": "node .claude/hooks/no-write-over.js",
                        "timeout": 10,
                        "statusMessage": "checking what is already there",
                    }
                ],
            },
        ]
    },
}

# ★ DERIVED, NEVER LISTED TWICE. Every hook file named in the declaration must exist, and each
# gets its self-test by convention. Adding a hook above is the whole registration.
SELFTESTS = {
    "no-shell-python.js": "_selftest.js",
    "no-write-over.js": "_selftest_writeover.js",
}


def load(path):
    """(obj, error). A parse failure is the finding, never an exception."""
    if not os.path.exists(path):
        return None, "MISSING"
    try:
        return json.loads(io.open(path, encoding="utf-8").read()), None
    except ValueError as e:
        return None, "MALFORMED - %s" % e


def main():
    restore = "--restore" in sys.argv
    bad = []

    print("")
    print("   TOOL CONFIG - the environment against its declared known-good state")
    print("   " + "-" * 66)

    if restore:
        io.open(SETTINGS, "w", encoding="utf-8", newline="\n").write(
            json.dumps(KNOWN_GOOD, indent=2, ensure_ascii=False) + "\n")
        print("   ⟶ .claude/settings.json REWRITTEN from the declaration.")
        print("     ⚠ The hook FILES are git's: `git checkout -- .claude/hooks` restores those.")
        print("")

    got, err = load(SETTINGS)
    if err:
        bad.append("settings.json %s  ⚠⚠ EVERY setting in it is OFF, silently - "
                   "the hook AND the permission bounds" % err)
    else:
        # ⚠⚠ THIS WAS HARD-INDEXED TO `PreToolUse[0].hooks[0]` AND WENT PARTLY INERT THE
        # MOMENT A SECOND HOOK LANDED (2026-08-22): the Write guard was registered, and this
        # printed *"the environment matches its declared state"* without ever looking at it.
        # ★ The SEVENTH inert guard on this project's record, and it was inert for about a
        # minute - caught only because the same turn that added the hook ran this.
        # ⟶ So the check now walks the DECLARATION. Adding a hook above extends it for free,
        # which is the only shape that does not rot: a check whose coverage is a CONSTANT
        # cannot notice the thing it was not told about.
        for want_e in KNOWN_GOOD["hooks"]["PreToolUse"]:
            m = want_e["matcher"]
            live = [h.get("command") for e in got.get("hooks", {}).get("PreToolUse", [])
                    if e.get("matcher") == m for h in e.get("hooks", [])]
            for want_h in [h["command"] for h in want_e["hooks"]]:
                if want_h not in live:
                    bad.append("the %s PreToolUse hook is NOT in settings.json (found: %s)"
                               % (m, ", ".join(live) or "nothing"))
        for kind in ("deny", "ask"):
            want = set(KNOWN_GOOD["permissions"][kind])
            live_p = set(got.get("permissions", {}).get(kind, []))
            missing = sorted(want - live_p)
            if missing:
                bad.append("permissions.%s is missing: %s" % (kind, " · ".join(missing)))

    # the hooks the settings point at must actually be there, and so must their self-tests
    for hook, test in sorted(SELFTESTS.items()):
        for f in (hook, test):
            if not os.path.exists(os.path.join(HOOKDIR, f)):
                bad.append("hooks/%s is MISSING - `git checkout -- .claude/hooks`" % f)

    # ★ and each must still BITE. A present hook that passes everything is the inert-guard fault.
    for hook, test in sorted(SELFTESTS.items()):
        path = os.path.join(HOOKDIR, test)
        if not os.path.exists(path):
            continue
        try:
            r = subprocess.run(["node", path], capture_output=True, text=True)
            if r.returncode != 0:
                bad.append("%s FAILS - %s does not behave as declared" % (test, hook))
            else:
                print("   ★ %-22s holds (%s)." % (hook, test))
        except OSError:
            print("   ~ node not found; %s was NOT run - not a pass." % test)

    # -- the EMBEDDED copy in RECOVER-AGENT.cmd must agree with the declaration above.
    #
    # ★★★ THIS IS THE PROMISE THAT FILE MAKES IN ITS OWN COMMENT, DELIVERED. Tier 3 of the
    # recovery writes settings.json out of the .cmd itself, which is a SECOND COPY of
    # KNOWN_GOOD - the exact fault this project keeps naming. A second copy is only acceptable
    # when a machine reconciles it, and this is that machine.
    # ⚠⚠ AND THE DRIFT WOULD SURFACE AT THE WORST POSSIBLE MOMENT: nowhere at all until a
    # recovery is actually needed, and then it would restore a config nobody declared.
    cmdp = os.path.join(REPO, "RECOVER-AGENT.cmd")
    if not os.path.exists(cmdp):
        bad.append("RECOVER-AGENT.cmd is MISSING - the outside lever is gone")
    else:
        body = io.open(cmdp, encoding="utf-8", errors="replace").read()
        lines = []
        for ln in body.split("\n"):
            t = ln.strip()
            if t.startswith(">") and '"%S%" echo ' in t:
                lines.append(t.split('"%S%" echo ', 1)[1].rstrip())
        if not lines:
            bad.append("RECOVER-AGENT.cmd has NO embedded settings - tier 3 would write nothing")
        else:
            # cmd `echo` needs ^ before some characters; none are used here, but strip defensively
            emb, eerr = None, None
            try:
                emb = json.loads("\n".join(lines).replace("^", ""))
            except ValueError as e:
                eerr = str(e)
            if eerr:
                bad.append("the EMBEDDED copy in RECOVER-AGENT.cmd is not valid JSON - %s" % eerr)
            elif emb != KNOWN_GOOD:
                bad.append("the EMBEDDED copy in RECOVER-AGENT.cmd has DRIFTED from the "
                           "declaration - a recovery would restore a config nobody declared")
            else:
                print("   ★ the embedded copy in RECOVER-AGENT.cmd matches the declaration.")

    _, lerr = load(LOCAL)
    if lerr == "MISSING":
        print("   ~ settings.local.json absent. Personal grants, earned by use - not restorable,")
        print("     and deliberately not captured here (it is gitignored to stay personal).")
    elif lerr:
        bad.append("settings.local.json %s - its allow-list is silently OFF" % lerr)

    print("")
    for b in bad:
        print("   [!] %s" % b)
    if bad:
        print("")
        print("   ⟶ RESTORE: `py operations/toolcheck.py --restore` rewrites settings.json from")
        print("     the declaration above; `git checkout -- .claude/hooks` restores the hooks.")
        print("     ⚠ The restore prompts, by design (PROTOCOL 1c) - it is a decision.")
    else:
        print("   ★ the environment matches its declared state.")
    print("")
    print("   ⚠ THIS CHECKS THE CONFIG, NOT THE BEHAVIOUR IT BUYS. A settings file can be")
    print("     perfect and the harness still not have reloaded it - the tell is a refusal that")
    print("     does not fire when you deliberately trip it.")
    print("")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
