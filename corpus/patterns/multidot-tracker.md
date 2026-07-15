# pattern: multidot-tracker

_status: **candidate primitive — live-discovered by Battlewrath (2026-07-15, in-game), closure-stubbed CLEAN, source-cited.**
Provenance: `export_20260715_082934_01.txt` → `corpus/planning/out/DOT(S).docket.json`. The ambient multi-dot tracker,
BUILT-IN — the wall recorded in buckets.md ("multi-unit on 3.3.5 = least-verified") is now OPEN with both witnesses._

## What it is

**One aurabar aura tracks every dot on every target** — WA's `unit: "multi"` engine is CLEU-driven
(`BuffTrigger2.lua:3671` registers `COMBAT_LOG_EVENT_UNFILTERED`; `MatchesTriggerInfoMulti` matches by sourceGUID =
the ownOnly equivalent), so it needs no nameplate units and works on the 3.3.5 client. `showClones` spawns a bar per
dot instance per target; the dynamicgroup wrapper with **`sort: ascending`** self-orders by time remaining — *the top
bar is always the next dot to fall* (the ambient tab-prompt, restored).

## The signature (from the closed dockets — Battlewrath's live config verbatim)

- group (dynamicgroup): `sort: ascending` · `animate: true` · border styling taste
- member (aurabar): `unit: "multi"` · `useName: true` + `auranames: [one id per DOT FAMILY]` · `ownOnly: true` ·
  `debuffType: HARMFUL` · `showClones: true` · `useGroup_count` + `group_count` — **REQUIRED for multi mode**
  (Battlewrath: "you have to define a target count"; 1 = from one target up, user input)
  - **GRADING FLAG:** intended operator `>=`, but the export stores `<=` — if live, `<= 1` hides bars the moment a
    SECOND target is dotted. Verify by dotting two mobs; flip the Unit Count operator if they vanish.
- taste layer (Battlewrath's seat, riding verbatim): colored bars per dot · the trailing SPARK · group border +
  `borderBackdrop: Blizzard Marble` background
- Note (source, `BuffTrigger2.lua:2592/2707`): `rem` checks don't apply in multi mode — expiry urgency comes from the
  ascending sort, not a rem gate.

## The generalization (the contract it wants to become)

**Per class: one docket.** `auranames` = the class's DoT family rep-ids — exactly the list the Target-tracker select
already computes per class:spec (the batch press's own members). "One bar to do them all": a per-class multidot
companion to the unit=target pack. Also a natural **picker scaffold** shelf item.

## Sheet boundaries flagged by the stub

`smoothProgress` · `sparkDesaturate` — aurabar options not on our display sheet (harvest boundary, minor).
