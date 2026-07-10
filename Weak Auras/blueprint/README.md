# Blueprint — the coherent pipeline (reference plane)

The single top-down statement of **what we're building toward**. The strand docs
(`../CHAIN.md` + siblings) describe what's *built*, in pieces; this describes the
*intended coherent model*, component by component. Fresh basis — if it proves
wrong, we replace it wholesale, cheaply.

## The goal
Author HUD content by expressing **intent** (what to display, where) and have the
system assemble it into working, WA-valid auras — so complex auras ship from
understood, indexed primitives instead of hand-built tables.

## Vision & sequencing

**North star — a community service.** The end goal is a *workshop taking
commissions*: a requester brings a user story ("flare when Voidseeker procs") and
the pipeline returns a working, generic (multi-user) WeakAura. The reasoning,
assembly, and final fitness stay **in-house** — the requester's only job is the
story, plus optional *homework* (a spell ID to drop into a trigger). The data
pipeline (DBC + talent crawler) is the auto-fill that lets a user story *survive
translation* without anyone logging onto every class to live-sample it. An
**agent** writes the *docket* (the structured inventory entry) from the story,
bounded to the known slice vocabulary + data — gaps are marked as homework, never
guessed, and a homework package is self-verifying (the game lights up on import,
or it doesn't).

**Current framing — prove it on the HUD first.** We are deliberately framed
around making the **HUD** work (Necromancer as proof, since Battlewrath plays it).
That is *not* the end goal — it's the proof that we can **constrain the unknowns**:
mask, blocks, slices, assembler, and WA's engine, composed into a real working
output. Community service is **downstream**, and waits on two things: a **factual
basis** (the DBC + talent data) and **working outputs** (the pipeline proven
end-to-end). Don't chase the service before the proof lands — the HUD is how we
earn the right to it.

## The flow
```
[4] Class inventory — per slot: a slice + fills            (intent, authored)
      on  [1] Mask   — slot families: where / how much room (computed authority)
      of  [2] Slices — logical display operators: what      (hand-authored vocabulary)
      from[3] Blocks — WA code snippets + holes             (WA's parts, indexed)
   |
   v
[5] Assembler — resolve slice->blocks, distribute into lanes, allocate indices, pair
   |   (a *reasonable* data table)
   v
[6] WA Modernize — canonicalize to WA-valid form (harnessed headless)
   |
   v
   encode -> import string -> paste in-game
```

## Who owns what
| stage | owner | note |
|---|---|---|
| Mask | computed geometry | ours; live captures only validate |
| Slices | **human author** | ours — the real work |
| Blocks | WeakAuras | WA's ontology; we index, not invent |
| Inventory | human / agent | the authoring surface |
| Assembler | machine | dumb, mechanical, zero reasoning |
| Canonicalize | WeakAuras | `Modernize`, harnessed |

## Status
- **Built:** Mask ✔ · Blocks ✔ · Assembler (reconstruction, 59/59) ✔ · WA-engine harnessable ✔
- **Next:** Slices (vocabulary) ✎ · Inventory (redesign) ✎ · Assembler (generative distribute+pair) ✎

## Components
1. [Mask](1_mask.md) · 2. [Slices](2_slices.md) · 3. [Blocks](3_blocks.md) · 4. [Inventory](4_inventory.md) · 5. [Assembler](5_assembler.md) · 6. [WA engine](6_wa_engine.md)

Supporting (not in the runtime path): the **corpus** (`../CORPUS.md`) reads live
auras as intent / discovery for authoring slices; **validators** (`../mask_validate.py`,
`../WA_VALIDATION.md`) are drift detectors, not builders.
