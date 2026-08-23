---
name: tools
description: Find what tooling already exists on this repo before building, naming, or writing a new script — 158 tools across 13 bench desks, indexed live from their own docstrings. Use before creating any tool or checker, when a task sounds mechanical and something may already do it, when picking a filename under a tools directory, or when asked what a tool does.
---

# The tool desks — ask before you build

**The desks are large and were unindexed until 2026-08-22:** 57 tools in `addons/tools` alone,
**158 across 13 desks**. Nothing enumerated them, so every agent's sense of what existed was
whatever it happened to have opened.

## Ask the desk

```bash
py operations/emit_tool_index.py
```

```bash
py operations/emit_tool_index.py --find cite
```

| | |
|---|---|
| *(no argument)* | every desk |
| `<path>` | one desk, e.g. `addons/tools` |
| `--find <word>` | only tools whose name or first line matches |
| `--gaps` | only tools that describe nothing — they cannot be indexed |

★ **There is no index file, deliberately.** It reads each tool's module docstring at run time and
prints. A hand-written `TOOLS.md` would be a second copy of a fact the tools already state, and
this repo's own log warns about that shape: *a home POINTS; an index that restates is the second
copy that drifts.* Nothing here can go stale, because nothing is stored.

## ⚠ Before you create a tool

**A new file's NAME is a claim about what already exists.** Check it — one command, before writing
a line:

```bash
py operations/emit_tool_index.py --find <the word in your intended name>
```

⟶ **Why this skill exists.** On 2026-08-22 I wrote a new mutation harness to
`addons/tools/mutate.py` and committed it. That path already held a **342-mutation** suite for the
Lua smokes, many sessions old, carrying six bad tests, one live bug and its own ruling. I used
`Write` on a path I had never read. Restored byte-exact from `HEAD~1` only because the tree was
clean and it was caught the same session. **No checker, no test and no commit noticed.**

⚠⚠ Worse than the overwrite was the framing: the new tool's header claimed *"nobody was checking
the checkers."* The harness existed — it simply did not reach the Python tools. **A rationale that
begins "nobody has…" is an unchecked claim, and the absence is the first thing to measure.**

## The guard that does not depend on you looking

This skill is **pulled** — it helps only when someone chooses to ask. The pushed half is
`.claude/hooks/no-write-over.js`: a `Write` onto an existing **tracked** file asks first and shows
that file's own first documentation line and commit count. It fires whether or not anyone looked.

⚠ Neither replaces the other, and neither replaces reading. **The index reports what a tool SAYS
about itself, never what it does** — a stale first line indexes staleness.

## Adding a tool to the desk

A docstring is the whole registration. The house form, and it was already universal at 57 of 57
before anyone enforced it:

```python
r"""name.py - the dumb action it performs, in one line.

    py addons/tools/name.py            what the plain run does
    py addons/tools/name.py --flag     what the flag changes

★★★ WHY THIS EXISTS - the failure it watches, dated, with the measurement.
⚠ WHAT IT CANNOT SAY - the honest ceiling, kept on screen rather than hidden.
"""
```

★ Name it by its **dumb action**: `check_` proves a property, `emit_` derives from source,
`read_` parses one thing. Creation-words belong only to tools that derive from a source.

## Related

- **boot** — run the session boot sequence first; it routes you to your bench shelf and lane state.
