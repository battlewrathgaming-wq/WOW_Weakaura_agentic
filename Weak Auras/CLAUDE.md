# Working agreement for this folder

Settled with Battlewrath 2026-07-06, after a session where feedback
about the Cast Bar/Swing Timer icon spacing got treated as a bug report
and acted on immediately - twice, in opposite directions, before actually
being aligned on what was true.

**Discuss intent before acting.** When Battlewrath points something out
about a build, a design choice, or something observed in-game, that is
an invitation to discuss the issue - not an instruction to immediately
edit, rebuild, or "fix" anything. Some things Battlewrath says are
observations, some are open questions, some are firm requests - don't
collapse all three into "make a change now." Ask, or reason it through
together, before touching a template or regenerating an import string.

**Correction comes once we're in alignment**, not before. If a real fix
is warranted, agree on the diagnosis and the intended fix first, *then*
implement it - not implement-first-explain-after.

This doesn't mean stall on everything or ask permission for trivial
steps - it means treat "here's what I noticed" as the start of a
conversation, the same way a colleague would, rather than as a green
light to start editing.

**The Lua emulation (`wa_lua_verify/`) speeds up catching gaps - it
isn't ground truth.** Settled 2026-07-06, the same day that tool was
built, directly motivated by the subtick field-parity bug (a fragment
missing 3 fields, discovered only after a live import came out wrong).
`wa_lua_verify` runs real WeakAuras source under a real Lua 5.1
interpreter, but it stubs the entire game API and its own findings are
still a simulation, not the client. When a finding from it is genuinely
uncertain or novel - not just re-confirming an already-corroborated
pattern - validate it against a real in-game export before treating it
as settled, the same way the subtick bug itself only became fact once
Battlewrath's real re-exported aura was decoded and diffed. **This is
not a ritual to run on every trivial change** - if a result already
matches a well-established, previously-confirmed pattern, take it as
sufficient and move on; reserve the extra confirmation step for real
uncertainty, not as box-ticking on things already known to be true.

**When a `.py`/`.json`/`.md` file you've edited more than once this
session throws a confusing error (unterminated string, truncated
content) on execution, suspect the sandbox's own FUSE mount-lag bug
before suspecting your own edit.** Run `python3 fuse_check.py <file>`
(see `DEV_TOOLS.md`'s tool 5) - if the reported line count doesn't match
what the Read tool just showed you, bash is serving stale bytes, not a
real syntax error. Confirmed 2026-07-06 this isn't limited to `.py`/
`.json` - four freshly-edited `.md` files all showed the same symptom
during a documentation audit.

**Fix, cheapest option first (also confirmed 2026-07-06 via a real
repro):** use the Write tool to save the Read-tool-confirmed-correct
content to a brand-new path (anything untouched this session), then run
`python3 fuse_check.py --resync <fresh_path> <stale_path>` - this copies
the fresh bytes over and verifies the hash matches in one step. Much
less error-prone than hand-typing a full heredoc for a large file. A
bash heredoc (`cat > path << 'EOF' ... EOF`) using the Read-tool content
still works as a fallback if a fresh temp file isn't practical - that
was the only known fix before `--resync` existed.

**Deleting a file via bash `rm` inside this project folder will fail
with "Operation not permitted" - this is NOT the FUSE bug, it's Cowork's
own deliberate file-protection safeguard**, confirmed 2026-07-06 (a
plain scratch test file, written once and never edited, still couldn't
be `rm`'d). Don't read a delete failure as more FUSE staleness. The
actual fix: call `mcp__cowork__allow_cowork_file_delete` with the file's
**VM path** (the `/sessions/...` path bash sees, not the Windows
`F:\...` path - the tool errors with "Could not find mount" on the
Windows-style path), which prompts the user for permission and then
allows deletion for that folder for the rest of the session.

**Git via the sandbox's bash bridge - updated 2026-07-07, supersedes the
2026-07-06 blanket ban below.** The original note (kept for context) said
never run `git` through the sandbox at all, based on one incident where
`git init`/`git add` wrote a `.git/config` full of null bytes - treated
as unrecoverable write corruption. On 2026-07-07, a full catch-up session
ran 8 real `git add`/`commit` operations through bash against this same
mounted repo: 7 succeeded cleanly, and the one hiccup (a `git add` hit
the FUSE-lag bug on `.git/index` itself, "bad signature 0x00000000,
index file corrupt") was fully recoverable - `git fsck --full` confirmed
zero object-store corruption, all working-tree files were confirmed
intact on disk, and a plain `git reset` (mixed, restores the index from
HEAD without touching the working tree) fixed it in one command. That's
the same *class* of bug as the general FUSE staleness note above (a
stale/inconsistent read, not a genuine write-path corruption) - not the
harder failure the 2026-07-06 incident described.

**Current working rule:** bash is fine for day-to-day `git add`/`commit`
- just verify between steps rather than chaining blindly: check
`git diff --cached --name-only` looks like what you expect before
committing, and if anything looks wrong (unexpected deletions, a
`fatal:`/`error:` from git itself, a file count that doesn't match), stop
and run `git fsck --full` before doing anything else. If `fsck` comes back
clean, `git reset` (mixed) is almost always the fix - it only touches the
index, never the working tree or the object store. If `fsck` ever reports
real object corruption (not yet seen, but the theoretical harder case),
that's when to fall back to the original 2026-07-06 fix: write a `.bat`
script and run it via computer-use double-clicking it in File Explorer,
so git executes natively on the user's machine, never through the bridge
- `git_push.bat`/`git_setup.bat` already do exactly this for push/init.
`git push` itself still can't run from the sandbox at all (no GitHub
credentials in that environment, unrelated to FUSE) - that step always
needs `git_push.bat` run locally regardless of how the commits were made.

Neither the local filesystem MCP (`mcp__filesystem__*`, read/write/list
only, no command execution by design) nor `Tools/project_index/` (a
search/metadata index, not a git tool) are alternatives here - they solve
different problems. There is currently no MCP-based way to run git; the
two real options remain bash-with-verification and computer-use-native.

Cheap extra insurance, independent of the above: **before starting a big
batch of git operations (like a multi-commit catch-up session), make a
dated copy of the whole project folder (or at minimum just `.git/`)
somewhere else on the F: drive.** `git push` to GitHub already gives an
off-machine copy of everything committed, but an occasional local backup
covers the gap before that push happens - cheap, no tooling needed, just
a copy-paste in File Explorer every so often (not after every commit,
just before/after a session with real risk - e.g. today's catch-up pass).

*(Original 2026-07-06 note, kept for context - the null-byte `.git/config`
incident above was the basis for it, root cause never independently
confirmed): a `git init`/`git add` run through the sandbox's bash tool
against the mounted Windows drive wrote a `.git/config` full of null
bytes - a real write corruption, not just a stale read a heredoc/resync
can fix. Its follow-on inability to delete the corrupted `.git` files
could itself just have been the delete-protection safeguard noted above
rather than a second FUSE symptom - never re-tested, so don't assume it
was FUSE-specific.)

**Compiler-change checklist + go word.** Settled 2026-07-06, after a
session where `template_filler.py`'s press-wash logic got rebuilt four
times (v3 through v6) off successive partial live-test reports, each
round starting before the prior one had even been confirmed correct in
practice - churn that should have been one conversation, not four
separate implement-first passes.

"Compiler" means anything that TRANSFORMS data into the final aura -
`build_templates.py`, `template_filler.py`, `layer_builder.py`,
`weakaura_codec.py`. It does NOT mean editing a class's own content data
(`Necromancer/inventory.py` and siblings) - that's just content, and
doesn't need this checklist, only the general "discuss intent before
acting" rule above.

Before editing any compiler file, walk through this out loud in chat
first, don't skip straight to a diff:
1. **Diagnosis** - what's actually wrong, in plain terms, and what
   evidence backs it (a real in-game report, a direct source read, or
   still-unconfirmed reasoning - say which explicitly).
2. **Fix** - exactly what will change, and just as importantly, what
   will deliberately NOT change.
3. **Blast radius** - which already-built abilities/layers does this
   touch, and does anything need rebuilding once it lands?
4. **Open questions** - anything not yet confirmed, named as a
   hypothesis, not stated as settled fact.

Then stop. Nothing in a compiler file actually gets touched until
Battlewrath says the go word: **"Go."** (Confirmed 2026-07-06 - "Go" is
fine, not a placeholder anymore.)

**Agreeing with the concept is not the go word.** This is the specific
failure this checklist exists to close: Battlewrath saying "yes" or
otherwise agreeing that a diagnosis/direction is correct is NOT
authorization to implement it - that's still discussion. Battlewrath,
2026-07-06: "Sometimes, when I am giving agreement to the concept, you
then rush off, and then the compiler gets touched. It's how we churned
through 3 versions when we could have developed through conversation
more." Concept-agreement and the go word are two different signals -
don't collapse them into one just because they often happen close
together. Post the 4-step checklist, let Battlewrath respond to it
(including just agreeing that the diagnosis is right), and keep talking
it through until "Go" is actually said - agreement on the idea can
arrive well before the go word does, and that gap is deliberate, not
wasted time.

**Verification and design lessons, as first principles (Witch Doctor
totem/beacon investigation, 2026-07-06).** These came out of a specific
session (totem display -> combat log capability inventory -> a
staleness-check design, refined against a real collaborator's
independent rebuild) but are stated here as generic, not tied to that
content:

1. **"Obviously safe" APIs need live verification too, not just
   custom/server-specific ones.** The `GetNumTalentTabs` lesson taught
   us to distrust server