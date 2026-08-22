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

---

## ★★ WHAT TO CHECK HERE FIRST, when something is behaving oddly

    a Bash command refused for no obvious reason   → the REFUSAL entries. Run
                                                     `node .claude/hooks/_selftest.js`; if the
                                                     15 cases hold, the hook is right and the
                                                     command is in command position.
    a tool that used to run and now prompts        → the PERMISSION entries.
    a checker that passes and proves nothing       → the CHECKER entries. ⚠ This project has now
                                                     recorded FIVE guards that went inert while
                                                     printing green (§457 · §458 · §465 · §472 ·
                                                     §511). **A green with a zero count beside it
                                                     is the tell.**

⚠ **AND THE ENTRY THAT IS MISSING IS THE ONE THAT WILL COST THE MOST.** A config change made and
not written here is invisible to exactly the person who needs it — which is the same failure this
project keeps finding in its documents, moved one layer out into the environment.
