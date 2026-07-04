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

**When a `.py`/`.json` file you've edited more than once this session
throws a confusing error (unterminated string, truncated content) on
execution, suspect the sandbox's own FUSE mount-lag bug before suspecting
your own edit.** Run `python3 fuse_check.py <file>` (see `DEV_TOOLS.md`'s
tool 5) - if the reported line count doesn't match what the Read tool
just showed you, bash is serving stale bytes, not a real syntax error.
Fix: rewrite the file directly via a bash heredoc using the Read-tool-
confirmed content, not by re-editing (the Edit tool's own view is
already correct - the problem is purely bash's separate view of the same
file).

See `README.md` in this folder for the actual project index/content map
- this file is process only.
