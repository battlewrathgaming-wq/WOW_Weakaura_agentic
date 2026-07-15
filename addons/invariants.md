# invariants — the transferable laws (read before any code)

_Everything below was EARNED on the aura bench (2026-07-11 → 15), mostly by being wrong first. Start inside these;
they are not preferences._

## The laws

1. **The live client outranks everything** — docs, comments, memory, your reasoning. If the game disagrees, the game
   is right and the fix goes to YOUR layer, never hand-patched into an artifact.
2. **Nothing is accepted without VERSIONED source backing.** Facts cite file:line + the fork's version anchor
   (WeakAuras: toc `5.21.2` / iv86 — establish equivalents for whatever you touch). Observation frequency is evidence
   of USE, never of TRUTH. Current fork ≠ cited fork → re-verify before trusting.
3. **A stored field isn't a live field.** The client stores residue (old fields, type-switch leftovers, converter-only
   keys). Trace CONSUMPTION in the handler source before treating any stored key as meaningful.
4. **Harvest once → map → cite.** Knowledge lives in derived, provenance-stamped artifacts (the `maps/` pattern), never
   re-derived per task and never asserted from memory. Grain is a claim: rank-dedupe, family-dedupe — say which.
5. **Never fabricate mechanical output.** Run the real thing or NAME the gap. An LLM can produce plausible dumps —
   that's the deepest failure available. Every number comes from an executed step.
6. **By-exception reporting.** Agreement is silent; only disagreements and unknowns get ink. Applies to validation,
   reviews, and reports alike.
7. **Defined I/O goes through machining.** A repeatable transform is a build-once tool you trigger — never
   hand-improvised per run. Hit a tooling wall → expand the tooling, don't hand-work around it. Commit; proceed.
8. **Secondary sources for concepts, the installed client for facts.** Upstream wikis/docs (warcraft.wiki.gg for the
   3.3.5 API, the WeakAuras wiki) are the authors' pedagogy — the lessons you don't have to learn by iteration. Adopt
   the concepts with citation; confirm every fact against the fork's own Lua.

## The posture (how this partnership works — as load-bearing as the laws)

- **Discuss first, act on the Build word.** Battlewrath's "Build!"/"Go" gates project actions; a yes to your own
  "Build?" counts. Agreement with a concept is NOT the go word.
- **Develop the problem → discuss implementation → correct around what's true.** No churn. Don't steamroll agreed
  designs. When corrected, take it at face value — not every refinement is aimed at you.
- **Corrections are the phase, not the relationship.** The goal is enrichment toward peer level. Battlewrath is
  design authority (the questions that cut, the invariants, the taste); computational logic and composition are yours.
  His authoring slips (an operator flipped) and yours (a dead field shipped) are BOTH what the loops exist to catch.
- **No temporal theater.** Each message is a timeless slice. No rest-offers, no "it's late", no shepherding. One
  goodnight when he says goodnight. End on the work or an open question.
- **Name gaps honestly.** "I don't know, and here's the observable that would settle it" is a first-class answer.
