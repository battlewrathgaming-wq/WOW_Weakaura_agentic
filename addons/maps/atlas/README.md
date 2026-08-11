# Atlas census — the client's named UI art, classified by CLAIM OF USE

**Emitted, never hand-edited.** Regenerate with:

```bash
py addons\tools\emit_atlas_census.py
```

## What question this answers

*"Which icon may we use, and which one already means something?"*

Icons carry language. Art the client already uses **owns a meaning here** — reusing it both
mis-states our signal and corrupts theirs. The bar is not "no client art", it is "no art that
already owns a meaning". This census draws that line from evidence instead of by eye, once,
for every project that needs an icon.

## Files

| File | Contents |
|---|---|
| `atlas.census.json` | the machine copy — every entry: `texture`, `w`, `h`, `claimed`, `claimedBy[]` |
| `atlas.routes.md` | human browse order, **grouped by texture sheet** — the useful order when hunting a look |
| `free.md` | just the unclaimed entries — the shortlist you actually pick from |

## Current numbers

**4,503** named entries from `SharedXML/AtlasInfo.lua` · **1,359 claimed** · **3,144 free**,
cross-referenced against **1,130** client source files.

## How the claim test works

An atlas name is *claimed* if it appears anywhere in the client's own Lua/XML outside the
registry that defines it. Zero references ⇒ unclaimed ⇒ free to give a meaning to.

Two honest limits, stated so nobody over-reads the output:

- **Substring matching.** A short name that is a substring of a longer one can read as claimed
  when only its neighbour is. Errs toward *claimed*, i.e. toward caution — the safe direction.
- **Dynamically-composed names** (`"Foo-"..state`) are invisible to a text scan. Before
  committing to a *free* entry that sits inside an obviously patterned family, eyeball the
  family in `atlas.routes.md`.

## ★ `claimed` is a FILTER, not a verdict

This census measures a **code binding** — who references this name. The rule it serves is
about the **meaning a player reads**. Those are not the same thing, and where they come apart,
the player wins.

Worked example (Battlewrath's ruling, 2026-08-12, on the supertrack beacon): its binding is a
*quest* supertrack. Its read is **"go here"**. No player ever learns the binding, so nothing is
corrupted by reusing it — and matching what they already follow is a gain.

**So a CLAIMED entry may still be fair use — when the meaning it owns is:**

1. **generic** — navigation, position, "here", a plain container; **and**
2. **the same as yours.**

Both, not either. Crossed swords are claimed by a meaning that is specific *and* different —
they stay out. `Waypoint-MapPin-Tracked` is claimed by a meaning that is generic *and*
identical — it's in.

Use `claimed` to shrink the field and to see **what a symbol already says here**. Then make the
call on the read, not the reference count.

## Reading the sizes

`w`/`h` are the registry's declared render dimensions. They are **not** always integers, and
in CoA's own art they are often Lua arithmetic (`85*0.24`) — the emitter evaluates those.

## Note on duplicates

The registry defines 18 keys more than once (19 extra lines). Lua takes the **last**, so those
earlier definitions are dead art. The emitter reports the count on every run.

## If the emitter ever refuses to write

It raises `PARSE INCOMPLETE` rather than emit a partial census. That guard exists because a
too-strict pattern once silently dropped 105 entries and the output looked perfectly healthy.
**Fix the pattern; never relax the guard.** Every drift found so far was in the fork's *custom*
art — see `addons/planning/satnav_ledger.md` F20.
