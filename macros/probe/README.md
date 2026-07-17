# probe — the composed ask. **Handoff to the addons bench.**

_Composed by the macros bench 2026-07-17. **The addons bench owns configuring COA_DevDump and the harness**
(Battlewrath: "they own configuring coadump") — this folder is the **payload and the method**, not a coadump task
file. Facts across the lane; not their build._

## Why this exists

`basis/conditionals.json` is **empty**, and no amount of source-reading will fill it. `SecureCmdOptionParse` is
called 49× in `ChatFrame.lua` and **defined nowhere in Lua** (the runtime census buckets it `stock-capi`), so the
conditional vocabulary lives in the client binary. The attested-usage seed measured **zero** — the client's own
shipped code contains no conditional literal anywhere.

**Asking the live client is the only channel.** This is the ask.

## What the addons bench needs to wire

| file | what it is |
|---|---|
| `probe_core.lua` | the evaluation core + the composed ask. **Resident Blizzard API only** — no addon namespace, no globals written, no state changed. Compiles clean under Lua 5.1 (`luac5.1 -p`, checked). Returns a flat result table. |
| `probe_rows.json` | all **76 rows** (63 flag / 13 target), each with its method, era signal, priority and expectation. The machine-readable ask. |

`probe_core.lua` ends with `return run` — a function returning the result table. Wire that into a task however the
v2 spine wants it; the harness shape is yours.

**Anti-cheat:** the core touches only already-resident API, so it does **not** need a client restart to try — it
runs from a plain `/run`, or interactively in the client's **built-in dev console** (`/luaconsole`, `/devconsole` —
confirmed present by Battlewrath 2026-07-17). That console is the cheap path: iterate interactively first, wire the
task once the shape is settled.

## The method — read the verdicts, don't guess them

**The whole difficulty in one line:** `[combat]` out of combat and `[madeupword]` are **both falsey**. One reading
cannot tell *unsupported* from *currently false*, so a naive probe silently reports half the vocabulary as missing.
Testing **both polarities** and reading the **pair** turns that ambiguous silence into a verdict:

| `[X]` | `[noX]` | verdict |
|---|---|---|
| true | false | **PROVEN-TRUE** — known, currently true |
| false | true | **PROVEN-FALSE** — known, currently false |
| false | false | **UNSUPPORTED** — parser rejects both ways |
| true | true | **IGNORED** — no-op / not evaluated |

## Run the control row FIRST

```
[@banana]
```

**One row, and it decides how to read all 13 target rows.** `@unit` and `[flag]` are not the same mechanism:

- If `[@banana]` returns `target="banana"` → **`@` is a pass-through string.** Support lives *downstream* (the
  handler's own special-casing → `Custom_HandleTerrainClick`; unit resolution), the polarity matrix does **not**
  apply to targets, and there is no `[no@cursor]`. The vocabulary question doesn't apply to `@` at all.
- If it returns nil → `@` is validated, and every target row means something different.

Both retail docs and CoA's own handler code point at pass-through (wowpedia: *"@unitId : Replace with any valid
unitId"*; `/cast` does `target:lower() == "cursor"`). **It's still a hypothesis until this row runs.**

## Priorities — where the information is

| priority | rows | why |
|---|---|---|
| **1-backport-test** | 4 | **SOURCED** — the wiki carries a `{{Patch}}` annotation dating it after 3.3.5a (`@cursor` 7.1.0 Legion *Blizzard-cited*, `pvpcombat` 7.3.0, `known` 10.0.2, `advflyable` 10.0.7). Present here only if **backported** — and this client backports freely (Legion/BfA `CompactUnitFrame`, Dragonflight `/kb`). **`@cursor` is a confirmed, dated backport already witnessed in CoA's own source**, so the pattern has a proof. Highest information per row. |
| **2-undated-test** | 9 | retail lists it, the ~2010 archive doesn't, **no patch annotation exists**. We genuinely **do not know** when it shipped — it may predate 3.3.5a and simply be undocumented in the archive. Absence is not evidence. The probe answers; no wiki can. |
| **3-baseline** | 59 | documented in the ~2010 archive ⇒ expected present on a 3.3.5a base. An `UNSUPPORTED` here is a real finding (removed, or never implemented on this fork). |
| **4-corroborate** | 4 | already source-corroborated; the probe confirms behaviour. |

_Tiers 1 and 2 were one bucket of "13 backport tests" until Battlewrath asked when `@cursor` actually shipped. It was 4 facts and 9 guesses wearing the same label — the ranking was inferred from **absence** in the archive, which is the very error this slice documents. Patch annotations are evidence; absence never was._

## Two standing limits — put these in the result, not just here

**A verdict is true of the moment it ran.** `PROVEN-FALSE` means *false right now*, not unsupported — the pair
handles that distinction. But context-bound flags (`combat`, `flying`, `mounted`, `indoors`, `stance:N`) want a
**second run in a different context** (mounted, in combat, indoors) to separate "false here" from "always false".
A single run is a snapshot.

**A probe proves only what it ASKS.** This ask-list came from the wiki chain (`../reference/`), so **the rim stays
open** — the output is a proven set with an honest rim, **never an enumeration**. Proof that absence proves
nothing: `@pettarget` is witnessed in this client's own Lua (`ChatFrame.lua:1471`) and appears in **no wiki**.

## Where the answers go

Verdicts flow back as `proof_mark` on `../reference/candidates.json`, and the **proven** set graduates into
`../basis/conditionals.json` — the only path by which anything becomes fact in this slice. `reference/` never
becomes `basis/` by itself.

## Regenerate

```
py macros\tools\compose_probe.py        reference/candidates.json -> probe/
```

Deterministic apart from `composed_at`. If the register changes (a wiki revid moves, a new source lands), re-compose
rather than editing these by hand.
