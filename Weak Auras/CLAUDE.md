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

**Git exists now (2026-07-06) - never run it through the sandbox's
mounted-folder bridge.** This project is tracked at
`https://github.com/battlewrathgaming-wq/WOW_Weakaura_agentic.git`, one
repo covering the whole project folder (not just `Weak Auras/`). This is
a harder failure than the general staleness bug above and is a genuine
FUSE write-path problem, distinct from the delete-protection note above:
a `git init`/`git add` run through the sandbox's bash tool against the
mounted Windows drive wrote a `.git/config` full of null bytes - a real
write corruption, not just a stale read a heredoc/resync can fix. (Its
follow-on inability to delete the corrupted `.git` files could itself
just have been the same delete-protection safeguard rather than a
second FUSE symptom - not re-tested since, so don't assume it was
FUSE-specific.) The working fix: write a `.bat` script (a normal
single-file write, which IS reliable) and run it via computer-use
double-clicking it in File Explorer, so git actually executes natively
on the user's machine, never through the bridge. Don't attempt `git` via
the bash tool against this project again - if a git operation is needed,
prepare a script and ask the user (or use computer-use) to run it
locally instead.

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

See `README.md` in this folder for the actual project index/content map
- this file is process only.
