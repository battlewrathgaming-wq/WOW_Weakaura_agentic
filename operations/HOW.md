# HOW — how the project works

_A touchstone: stable, slow to move. The architecture, so it's never re-derived. **Locked 2026-07-14** (agreed).
Changing this is a deliberate act, not an edit._

## Two halves, one membrane

The whole system is **two consolidated halves joined at the gate**. Invent on one side, validate at the seam, wrap on
the other.

```
CREATOR  (invent — "what should exist?")     GATE (validate)      ENGINE  (mechanical — "is it true? can we work it?")
  class inventories: an agent authors a    →  engine/gate.py   →    Fact_basis/   truth: sheets · contract · maps
   DOCKET per slot - the mechanical proof                           Production/   machine: stage · pickup · run · console
   a slot can function. ALL class                                   (plane/       the wrap gears, migrating in)
   knowledge lives here.
```

## The invariants (these are the rules, not preferences)

1. **The agent authors; the pipeline wraps.** Content is authored in the inventory / the relevant authoring space, with
   the domain knowledge already baked in (for a class ability, the watched spellId is *in* the docket). This is a **LAB** —
   per-class packs are the biggest *current* target, not the only axis; complex scaffolds (state-carrying compositions)
   are their own development track. **Past the gate, nothing authors content** — it structures and wraps the authored
   content into the minimal footprint headless WA needs; WA fills the rest.
2. **Generation lives only in the creator space.** "Generator" is a create-word; there is no generator in the pipeline.
   Steps past the gate have dumb-verb names (stage · gate · wrap · file · drain).
3. **Source (WA / contract) is the one vocabulary.** No creator dialect. The docket is WA-literal; every term is
   look-upable against the contract. Translation layers are where drift lives.
4. **The gate validates INPUT correctness.** Every field is agent input; correct → silent, incorrect (bad enum / spell-id
   not in the corpus) → blocks, unverifiable open box → soft flag. It doesn't resolve or author — it checks.
5. **Slim = minimal FOOTPRINT, never aliased names.** The docket declares only intent-bearing fields; canon completes
   the rest. Shortening field *names* was a bug; keeping the field *set* small is the design.
6. **Headless-green ≠ live-proven.** The fast proxy (canon.lua) confirms reimport-stability; the live client is the
   ground-truth authority.
7. **Nothing is accepted without source backing — versioned** (Battlewrath, 2026-07-14, for pattern-seeking and
   inspection). Corpus/observation frequency is evidence of USE, never TRUTH; acceptance requires the source citation
   plus the fork's version anchor (WeakAuras toc Version + internalVersion). Current fork ≠ cited fork → re-verify.

## The flow (one line)

`inventory authors docket → gate validates → Docket_stage/<PID> → pickup bundles a pack into one group string →
Docket_complete + register → import into WA`. A **PID is a pack id**; a pack is one group of many auras.

## The terminology bridge (2026-07-14 — the block era maps onto the proven machinery; concepts survive, terms matured)

| block era | now |
|---|---|
| blocks / BOM / parts catalog | **patterns** (`corpus/` — rebuilt through the gears: raw → stub → dockets → patterns; never recovered from blocks.db) |
| class inventory | **a class's CONTRACTS** (`creator/<class>/` hives — support materials, what makes a class tick; "populate the inventory" = press its contract set) |
| mask | **mask — unchanged in role, foldable into the contract.** The WHERE authority, and the **human-feel stabilizer**: it pins the layout/feel so machine regeneration can't drift the experience (a 90 doesn't shift to a 70 across re-presses) |
| fragment scrape / corpus jsons | **corpus/raw** (provenance-stamped ore) |
| blocks.db · native_blocks · gravity_wells | archaeology — superseded artifacts, nothing rebuilt *from* them |

Same five-part spine as ever, every part now load-tested: **mask** = WHERE · **contracts** = WHAT · **palette + maps** =
HOW expressed · **the machine** = join + wrap · **WA** = filter.

## The architecture is the touchstone; the folders are transitional

What's stable here is the two halves + the invariants. The specific **folders are in flux** — `plane/` deprecates, and a
lot of the current layout is sprawl we spun up so the main project could keep moving (lab-style). The discipline over
time is the reverse: **reduce the bloat, name and home the keepers.** So trust the invariants; don't ossify the layout.

## Where the detail lives (today)

`engine/README.md` · `engine/Production/README.md` · `engine/Fact_basis/README.md` · `engine/Fact_basis/sheets/README.md`
· the current build state in `operations/STATE.md`.
