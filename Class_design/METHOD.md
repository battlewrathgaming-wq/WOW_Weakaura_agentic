# Class design — the method

_The reasoning that translates across every class. Class/spec specifics live in
`<Class>/` folders; this floor holds what's universal. Pairs with `README.md`
(the folder's evidence-first discipline) — that file is *how* we admit a fact;
this one is *why* the work is useful and *what* it yields._

## The triangle

A build is the **expression of an intent.** Analysing one usefully means putting
three things side by side that normally live in different heads — the useful
reasoning is in the *gaps between them*, never in one alone:

- **EXPRESSION** — the player's *actual* nodes, captured not assumed:
  `tools/decode_build.py` off an export string, or the live walk in
  `tools/CAPTURE.md`.
- **INTENT** — the player's thesis: *the thing the build is working around.*
  The one corner no tool can read; it comes from the player, first.
- **MECHANICS** — how the game *actually* behaves: the fact-basis
  (`Input/*_talents.json`, `dependencies/coa_spells.json`, and the tested
  findings in each `<Class>/`).

## What the triangle yields (the work products)

1. **Realization report — does the build *mechanically* deliver its thesis, or
   only intend to?** (expression × mechanics, judged against intent.) The
   highest-value output, and it already bit: a build speccing **Scourge
   Disciple** for "archer haste" is running a *negative*-haste bug — premise
   false in-game (`Necromancer/FINDINGS.md`). A build can read well and play
   wrong; this is the check that catches it.
2. **Build-specific stat lean — "what stat helps *this* build most?"** No
   class-wide answer exists; the weight is a function of the nodes taken. Necro
   proved it: Stamina is a throwaway until the build carries the pet-scaling
   loop, then it's a damage stat. Derive the lean from the expression, not an
   average.
3. **Next-points map — opportunities toward the thesis.** The captured record's
   topology (`ConnectedNodes`, `RequiredIDs`, the cost matrix — see
   `tools/CAPTURE.md`) turns the tree into a graph: "next point" = reachable
   *and* adjacent to the thesis; "leaking" = points spent away from the key
   mechanic that could amplify it. The diff's `TARGETS` / `known-not-planned` is
   the live edge.
4. **Latent-synergy trace — compounding the player is under-realizing.** Graph +
   ability text surface hidden loops (the Stam → pet-HP → SP → pet-SP loop was
   invisible until traced). Each class hides its own.

Downstream, these feed the project's actual product: **the aura that makes the
key mechanic loud in play** — the realization check, enforced live.

## Why this beats "just theorycraft" (the fork)

Without the triangle, build advice is **invent-and-validate**: the guide guesses,
the player tests it in-game, at their cost, every time. Grounding the expression
in a real capture and judging it against tested mechanics makes build reasoning
**checkable against reality, not the guide's confidence** — the same fact-basis
method the whole repo runs on (`operations/HOW.md` §0), pointed at personal play.

## The honest boundary

The triangle reaches the **structural / mechanical** layer: coherence,
realization, allocation, synergy. It does **not** see **feel or rotation in the
moment** — whether the key thing is actually pressed when it matters. That's the
player's read + the auras. Name the boundary; never fake across it.

## Running it (per class/spec)

1. Player names the **thesis** (the missing corner) — without it, nothing else
   grounds.
2. Capture the **expression** (`tools/decode_build.py` / `tools/CAPTURE.md`).
3. Judge against the **mechanics** (the class fact-basis; gather or accept gaps,
   never invent — `README.md`).
4. Emit the work products into `<Class>/` as **durable talking points**, sourced.
