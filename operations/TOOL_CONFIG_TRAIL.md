# Tool config trail — what KIND of change, and where to read it

_Opened 2026-08-22 at Battlewrath's ask: **"A tool config trail. Not on what we changed as in
structure. But just the nature of the change and a reference to the file. For future trouble
shooting."**_

⚠⚠ **THIS IS NOT A DIFF AND NOT A RATIONALE.** Git holds the structure; the commit holds the
argument. **This holds the one thing neither surfaces when something misbehaves months later:
what CLASS of change was made to the environment, and which file to open.** ⟶ A troubleshooter
arriving cold asks *"has anything been done to the tooling that could cause this?"* — and that
question is answered by a short list, never by reading 500 commits.

★ **THE FORM, and it is deliberately narrow.** One line per change. If an entry needs a paragraph,
the paragraph belongs in the commit and the entry belongs here as a pointer to it.

    DATE   · KIND — one of: REFUSAL · PERMISSION · CHECKER · HOOK · LANE · REMOVAL
           · FILE(s)
           · why, in one clause
           · §commit

---

    2026-08-22 · REFUSAL     .claude/hooks/no-shell-python.js · .claude/settings.json
                             a PreToolUse(Bash) deny on shell-authored Python, after eight
                             silent-corruption failures across three sessions — the artefact
                             came out wrong and the command came out green.
                             §513   ⚠ self-test: .claude/hooks/_selftest.js (15 cases)

    2026-08-22 · HOOK        .claude/hooks/no-write-over.js · .claude/settings.json
                             a PreToolUse(Write) ASK when the target is an existing TRACKED
                             file, showing that file's own first documentation line and its
                             commit count — after a Write replaced a 342-mutation harness
                             that had been on the desk for months.
                             §529   ⚠ self-test: .claude/hooks/_selftest_writeover.js
                             ⚠ IT ASKS, IT DOES NOT DENY. Rewriting whole is ordinary; what
                             was missing was never permission, only KNOWING something was there.
                             ⚠⚠ PARTIAL BY CONSTRUCTION — it matches the Write TOOL, and this
                             bench authors most edits as Python scripts run through Bash, which
                             never reach that matcher. The gap is stated in the hook's header.

    2026-08-22 · CHECKER     operations/toolcheck.py
                             extended to the second hook — and the SHAPE was the finding: it
                             hard-indexed `PreToolUse[0].hooks[0]`, so it printed "matches its
                             declared state" while a newly registered hook sat unexamined.
                             It now walks the DECLARATION, so adding a hook extends the check
                             for free. Config-mutation tested: dropping either hook now bites.
                             §529   ★ the SEVENTH inert guard on this project, inert for about
                             a minute, caught only because the turn that added the hook ran it.

    2026-08-22 · LANE        .claude/skills/boot/ · .claude/skills/tools/
                             the first two SKILLS on this repo. A skill's description is PUSHED
                             into every session; a doc is PULLED and only answers questions
                             already being asked, which is how boot.py decayed.
                             `boot` runs the session boot sequence; `tools` asks the desks what
                             already exists before anything new is named.
                             §529   ⚠ NEITHER RESTATES A LIST. `boot` sends you to boot.py for
                             the lane names (the memory spine's copy was measured stale by one
                             day); `tools` prints from docstrings and stores no index.

    2026-08-22 · PERMISSION  .claude/settings.json
                             the config surface bounded against ITSELF: a hard DENY on editing
                             the permission file, and ASK on the settings and hooks. Because
                             *"once the door is open it's easy to keep entering it."*
                             §515

    2026-08-22 · HOOK       RECOVER-AGENT.cmd  (repo ROOT, on purpose — findable in a hurry)
                             the OUTSIDE LEVER: Battlewrath launches it when a config deadlocks
                             the terminal path and the agent cannot rescue itself, because the
                             tool it would use is the tool that is blocked.
                             `off` parks the project settings · `on` restores and verifies.
                             §517   ⚠ cmd built-ins only — no interpreter, no PATH lookup

    2026-08-22 · CHECKER    operations/toolcheck.py
                             the environment against a DECLARED known-good state, because a
                             malformed settings.json disables every setting in it SILENTLY —
                             the refusal hook and the permission bounds together.
                             §516   ⚠ four mutation classes proven to bite

---

## ★ SCOPE, DECIDED — PROJECT, and another repo EARNS it (Battlewrath, 2026-08-22)

> *"Project scope is preferred. Any other repos that get it are earned through usage here."*

Everything in this trail lives in **`.claude/` inside this repo** and travels with a clone.
**Nothing is at the user level** — `C:\Users\<user>\.claude\settings.json` does not exist, and
the install was never touched.

⟶ **So the refusal hook and the permission bounds apply HERE and nowhere else.** That is the
decision, not an oversight: a constraint is carried to another repo when working there has
*earned* it — the same *"on touch, never in a sweep"* rule this project applies to `grades`
coverage and to acceptance status tokens.

⚠ **RECORDED BECAUSE IT WILL BE RE-ASKED.** *"Shouldn't this be user-level so it holds
everywhere?"* is the obvious next thought — the Analyst proposed exactly that the turn before it
was settled. ★ The answer is no, and the cost of a user-level file is the reason: **it is one more
place a troubleshooter has to know to look**, which is the fault this whole trail exists to
prevent.

---

## ⚠⚠ A STATED LIMIT OF THE PERMISSION BOUND (found 2026-08-22 while proving the checker)

**The `deny` and `ask` rules bind the Edit and Write TOOLS. They do not bind the shell.** A
`cp` over `.claude/settings.json` rewrites it with no prompt — measured, three times, while
mutation-testing `toolcheck.py`.

★ **Left open deliberately, and here is the argument rather than an excuse:** closing it means a
hook refusing shell writes to `.claude/`, which would also refuse
`git checkout -- .claude/hooks` — **the documented restore path**. ⟶ A bound that blocks its own
remedy is worse than the gap.
⟶ And the bound's job is to stop the ROUTINE path becoming casual. **A shell rewrite of a config
file is already a deliberate act**; the Edit/Write path is the one that drifts.
⚠ It is written here because an unstated limit reads as a guarantee — which is the fault this
whole trail exists to prevent.

---

## ★★ WHAT TO CHECK HERE FIRST, when something is behaving oddly

    a Bash command refused for no obvious reason   → the REFUSAL entries. Run
                                                     `node .claude/hooks/_selftest.js`; if the
                                                     15 cases hold, the hook is right and the
                                                     command is in command position.
    the environment itself, before anything else   → **`py operations/toolcheck.py`**. It answers
                                                     "is the config still what we declared" in one
                                                     command, and catches the failure that reports
                                                     nothing: a malformed settings.json.
    a tool that used to run and now prompts        → the PERMISSION entries.
    a checker that passes and proves nothing       → the CHECKER entries. ⚠ This project has now
                                                     recorded SEVEN, the last two made the same
                                                     day they were caught. **A green with a zero
                                                     count beside it is the tell — and so is a
                                                     check whose coverage is a CONSTANT.**
    a Write that asks about a file you know        → the HOOK entries. `py operations/toolcheck.py`
                                                     runs every hook's self-test by name.
    "does something already do this?"              → **`py operations/emit_tool_index.py`**, or
                                                     the `tools` skill. Every desk, read from the
                                                     tools' own docstrings at run time. ⚠ It prints
                                                     the count; nothing else may restate it.

⚠ **AND THE ENTRY THAT IS MISSING IS THE ONE THAT WILL COST THE MOST.** A config change made and
not written here is invisible to exactly the person who needs it — which is the same failure this
project keeps finding in its documents, moved one layer out into the environment.
