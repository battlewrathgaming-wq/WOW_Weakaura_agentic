# HOW — how the project works

_A touchstone: stable, slow to move. The architecture, so it's never re-derived. **Locked 2026-07-14** (agreed).
Changing this is a deliberate act, not an edit. **Amended 2026-07-17** (Battlewrath) — §0, the method the whole
architecture is an instance of._

## 0. The method: a FACT BASIS per domain — why any of this exists

**The fork** (Battlewrath, 2026-07-17):

> _"I can ask you something. You have two options (or more). Invent. And then spiral manual validation testing until
> you invent the correct response. Or we can do the work now so your reasoning is based on factual data. We've done
> those steps for Weak auras. We've done that work for spells and classes. We've done it for addons. And now we do
> it for macro creation."_

**The economics are the argument, not the diligence.** Invent-and-spiral looks cheap — one fast answer. Its cost is
paid by **Battlewrath**, in **manual validation**, **every time, forever**, and it fails **silently**: a plausible
wrong answer is indistinguishable from a right one until it's tested in-game. A fact basis is paid **once**,
**mechanically**, and then every answer over that domain is grounded. **This is arithmetic, not thoroughness.**

**Done, in order — the pattern, not a one-off:**

| domain | its basis |
|---|---|
| WeakAuras | `wa_index/` → `engine/Fact_basis/` (sheets · contract · maps) |
| spells + classes | `Input/*_talents` · `coa_spells` · `class_table` · the class inventories |
| the client (addons) | `addons/maps/census/` (declared × baseline × runtime) |
| macros | `macros/` (basis · reference · probe) — 2026-07-17 |

**What makes something a basis** (not just notes): every fact **sourced or proven** · **grain stated, per domain**
— they are not all the same standing, and each file says its own · **regenerable** by one command · **version-anchored**
(sha256/revid; fork moved ≠ cited anchor → re-emit) · and **honest about its rim** — an empty file that says
*"unproven, and here is exactly how"* beats a complete-looking one. **Reference ≠ authority**: `corpus/` and
`macros/reference/` feed *intent*; they never become fact by sitting nearby.

**§1's ENGINE half is this method applied to WA.** The census is it applied to the client; `/macros/` to macros. The
architecture below is an *instance* of §0 — which is why invariant 7 (source backing, versioned) is a rule and not a
preference.

## 1. Two halves, one membrane

The whole system is **two consolidated halves joined at the gate**. Invent on one side, validate at the seam, wrap on
the other.

```
CREATOR  (invent — "what should exist?")     GATE (validate)      ENGINE  (mechanical — "is it true? can we work it?")
  class inventories: an agent authors a    →  engine/gate.py   →    Fact_basis/   truth: sheets · contract · maps
   DOCKET per slot - the mechanical proof                           Production/   machine: stage · pickup · run · console
   a slot can function. ALL class                                   (plane/       the wrap gears, migrating in)
   knowledge lives here.
```

## 2. The invariants (these are the rules, not preferences)

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

## 3. The flow (one line)

`inventory authors docket → gate validates → Docket_stage/<PID> → pickup bundles a pack into one group string →
Docket_complete + register → import into WA`. A **PID is a pack id**; a pack is one group of many auras.

## 4. The terminology bridge (2026-07-14 — the block era maps onto the proven machinery; concepts survive, terms matured)

| block era | now |
|---|---|
| blocks / BOM / parts catalog | **patterns** (`corpus/` — rebuilt through the gears: raw → stub → dockets → patterns; never recovered from blocks.db) |
| class inventory | **a class's CONTRACTS** (`creator/<class>/` hives — support materials, what makes a class tick; "populate the inventory" = press its contract set) |
| mask | **mask — unchanged in role, foldable into the contract.** The WHERE authority, and the **human-feel stabilizer**: it pins the layout/feel so machine regeneration can't drift the experience (a 90 doesn't shift to a 70 across re-presses) |
| fragment scrape / corpus jsons | **corpus/raw** (provenance-stamped ore) |
| blocks.db · native_blocks · gravity_wells | archaeology — superseded artifacts, nothing rebuilt *from* them |

Same five-part spine as ever, every part now load-tested: **mask** = WHERE · **contracts** = WHAT · **palette + maps** =
HOW expressed · **the machine** = join + wrap · **WA** = filter.

## 5. The two benches (locked 2026-07-15 — the inter-bench charter)

Same grammar on both benches — **contracts that generate from source, cross-validation** — different lanes:

| bench | lane | owns |
|---|---|---|
| **addons/** | **Lua → WoW** heavy tasks | client-side Lua, capture/harvest tooling, **CUSTOM CODE** (the scaffolds' Lua) |
| **the aura bench** (creator/corpus/engine) | **Lua → WA → WoW** tasks | WA repeatability, design, taste, **dockets**, the pattern corpus, closure |

**There is no court.** Both information bases enrich each other (handoffs: their captures/facts → our stamps/patterns;
our gears' fixes → their inheritance), but the conversations stay BOUNDED — each bench keeps its own focused context.
The guardian-health-tracker handoff (2026-07-15) is the proven flow.

## 6. The architecture is the touchstone; the folders are transitional

What's stable here is the two halves + the invariants. The specific **folders are in flux** — `plane/` deprecates, and a
lot of the current layout is sprawl we spun up so the main project could keep moving (lab-style). The discipline over
time is the reverse: **reduce the bloat, name and home the keepers.** So trust the invariants; don't ossify the layout.

## 7. Where the detail lives (today)

**Per-basis (§0):** `engine/Fact_basis/README.md` + `sheets/README.md` (WA) · `addons/maps/census/README.md` (the client) · `macros/README.md` + `macros/reference/README.md` (macros, incl. the reference≠authority line).
**The machine:** `engine/README.md` · `engine/Production/README.md`.
**Now:** `operations/STATE.md` (where we are) · the per-bench lane files (`Addons_load.md`, `Macros.md` — forecasts + standing cautions).
