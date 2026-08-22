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

    2026-08-22 · PERMISSION  .claude/settings.json
                             the config surface bounded against ITSELF: a hard DENY on editing
                             the permission file, and ASK on the settings and hooks. Because
                             *"once the door is open it's easy to keep entering it."*
                             §515

    2026-08-22 · CHECKER    operations/toolcheck.py
                             the environment against a DECLARED known-good state, because a
                             malformed settings.json disables every setting in it SILENTLY —
                             the refusal hook and the permission bounds together.
                             §516   ⚠ four mutation classes proven to bite

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
                                                     recorded FIVE guards that went inert while
                                                     printing green (§457 · §458 · §465 · §472 ·
                                                     §511). **A green with a zero count beside it
                                                     is the tell.**

⚠ **AND THE ENTRY THAT IS MISSING IS THE ONE THAT WILL COST THE MOST.** A config change made and
not written here is invisible to exactly the person who needs it — which is the same failure this
project keeps finding in its documents, moved one layer out into the environment.
