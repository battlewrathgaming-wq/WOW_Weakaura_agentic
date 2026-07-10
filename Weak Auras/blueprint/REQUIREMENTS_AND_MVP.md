# Requirements inventory + MVP target

Acceptance criteria per element (what "satisfied" means), and the thinnest
end-to-end test to prove the vertical. `[✔]` built · `[~]` partial · `[✎]` not yet.

## Requirements per element

**1 · Mask** `[✔]`
- slot-ID → `{anchor x,y · budget w,h · region · composition}`, a queryable lookup.
- stable slot IDs the docket can reference.

**2 · Blocks** `[✔]`
- block-ID → `{code_template (invariant) · holes · kind}`.
- each block knows its **lane** (region / trigger / condition / subregion / load) — the assembler distributes by lane.
- the blocks a chosen slice needs all exist.

**3 · Slices** `[✎ — critical]`
- a slice **definition schema**: `{ name · members:[{block-ID, lane, role}] · pairing:[{condition checks trigger-role → property: sub.M | region}] · required_fills:[hole → meaning] }`.
- a slice **library** (store + reference by name).
- ≥1 slice defined **authoritatively from a reference aura** (not guessed).
- fills declared: which holes the docket must provide, which are homework-able.

**4 · Docket / inventory (the IR)** `[✎]`
- format: `[{ slot-ID · slice-name · fills:{hole:value} · homework:[unfilled holes] }]`.
- human-readable **and** machine-parseable.
- references only known slots + known slices (checkable before assembly).

**5 · Assembler (generative)** `[~ reconstruction ✔, generative ✎]`
- consume a docket → per entry: resolve slice→blocks · place region at the mask anchor · **distribute** blocks into lanes at the next free index · **fill** holes · **pair** (emit conditions wiring trigger-index → `sub.M.<prop>` | region property) · mint uid + envelope.
- sequential index allocation (the join spec).
- emit a *reasonable* data table (WA finishes it).
- single-slice/single-slot first; multi later.

**6 · WA engine (Modernize)** `[~ harnessable ✔, fidelity partial]`
- run headless, canonicalize the assembled table.
- **full-fidelity stubbing**: identify + stub the real WA deps the migrations touch (beyond the current 3) so output is *correct* for our input, not merely error-free.
- encode canonical table → import string.

**7 · Reference data (DBC / talent)** `[~ — MVP skips]`
- spell name/intent → spell ID(s) + params (cooldown, duration).
- MVP: hand-provide the ID; requirement deferred.

**8 · Resolver / agent** `[✎ — MVP skips]`
- user story → docket, bounded to known slices + data, homework-marked, **no invented mechanisms**.
- MVP: hand-author the docket; requirement deferred.

**9 · Validator** `[✔ strong]`
- `wa_validate`: assembled fields conform to WA schema.
- `Modernize`: canonicalization (doubles as validation).
- **the game**: final import + behaviour check — the loud one.

## MVP target — one slot · one slice · one aura · end-to-end

Prove the *backend vertical* with the fewest new parts.

- **Slot:** one rotation slot, e.g. `Tier1_2`.
- **Slice:** a **cooldown-tracker-with-desaturate** — `region.icon + trigger.spell.action_usable + condition(trigger → desaturate)`. Minimal, but it exercises a real **trigger→condition pairing** (the generative join), not just a bare icon.
- **Docket (hand-authored):** `{ slot: Tier1_2, slice: cooldown_tracker_desat, fills: {spell_id: <a real Necro ability>} }`.
- **Flow:** docket → generative assembler → data table → `Modernize` → import string → paste in-game.
- **Short-circuits (deliberate):** hand-author the docket (skip the resolver), hand-provide the spell ID (skip DBC). This isolates the two riskiest unbuilt pieces — the **generative join** and **Modernize full-fidelity** — and proves them before we invest in the resolver or the data pipeline.
- **Acceptance:** imports clean; the icon appears at `Tier1_2`'s anchor; it desaturates on cooldown. Bonus: `weakaura_codec` decode round-trips the assembled table.

**Why this first:** it's the compiler smoke-test — one input, all the way through the mechanical spine (slice def → assemble → canonicalize → import), on one class we can eye-check in-game. If it lands, components 2–6 + 9 are proven end-to-end and only the resolver + data remain to *scale* it. See [README](README.md), [REFERENCE_MODEL](REFERENCE_MODEL.md).
