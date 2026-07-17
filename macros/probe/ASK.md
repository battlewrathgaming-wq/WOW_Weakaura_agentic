# ASK — one bounded capture, for the addons bench

_Staged by the macros bench 2026-07-17. **You own the harness** (COA_DevDump config, task file, envelope, deploy) —
this is the payload and the read. Your backlog's standing item: "addon-side captures may serve where source-scans
stall." This is that case, exactly._

## The bound

**One task. One pass. ~90 reads. No iteration, no arguments, no follow-up needed to make it useful.**

| | |
|---|---|
| **calls** | 63 flag pairs (126 `SecureCmdOptionParse`) + 13 target reads + 1 control + ~30 context reads |
| **writes** | none — pure reads, no state touched, no globals set |
| **API** | resident only; **every call verified present** in `maps/census/runtime/globals.json` before composing |
| **restart** | **not needed to try it** — plain `/run` or the dev console (`/luaconsole`) |
| **runtime** | single synchronous pass, no cycling, no event listeners |

## Why it's worth a pass

`basis/conditionals.json` is **empty and cannot be filled from source.** `SecureCmdOptionParse` is called 49× in
`ChatFrame.lua` and **defined nowhere in Lua** (your census buckets it `stock-capi`), so the conditional vocabulary
lives in the binary. The attested-usage seed measured **zero** — the client's own shipped code contains no
conditional literal anywhere. Asking the live client is the only channel there is.

## What to run

`probe_core.lua` — self-contained, ends with `return run`. Compiles clean under Lua 5.1 (`luac5.1 -p`) and has been
exercised headlessly against stubs (shape verified; **the stub is a simulation, the client is the arbiter**).

`run()` returns one flat record, `schema = "macros.probe.raw/1"`:

```
{ schema, context = {...}, control = {...}, flags = { [tok] = {pos=,neg=} }, targets = { [tok] = {action=,target=} } }
```

Land it as-is. **Please don't reshape or summarise it** — see below.

## The one thing that matters: land it RAW

**This capture emits observations. It decides nothing.** An earlier version computed verdicts (`"PROVEN-TRUE"`…)
in-game; that bakes one interpretation into the record, and if the matrix is wrong the raw is gone and the pass
costs a whole client session to redo. `flags[x].pos` / `.neg` are the parser's own returns. Verdicts get **derived
offline, in a map**, re-derivable forever without touching the game again.

> "We lean into emission rather than interpretation. Reasoning happens against verified facts." — Battlewrath

Broad now, consolidate after. **Get the data set broad; the maps come next.**

## Read the control row first

`[@banana]` — a nonsense unit. **One row decides how all 13 target rows are read:**

- `target == "banana"` → `@` is a **pass-through string**; support lives downstream (the handler's own
  special-casing → `Custom_HandleTerrainClick`, unit resolution). The polarity matrix does **not** apply to
  targets; there is no `[no@cursor]`.
- `nil` → `@` is validated, and every target row means something else.

Both retail docs and CoA's handler code point at pass-through. **Still a hypothesis until this row runs.**

## Why the context stamp is not padding

A conditional *claims* to reflect a game state. The stamp is an **independent witness of that same state**, so the
map can triangulate instead of assume:

- `[combat]` false **with** `inCombat=false` → consistent (currently false).
- `[combat]` false **with** `inCombat=true` → a real anomaly (broken, or unsupported).

Without it, every context-bound flag is unreadable and half the pass is wasted. This is why the record carries
`inCombat`, `mounted`, `flying`, `indoors`, `shapeshiftForm`, `actionBarPage`, `hasTarget/Focus/Pet`, modifier keys,
`classToken`, etc.

**`classToken` note:** captured as the *token* (`DEATHKNIGHT`, `SONOFARUGAL`…), not the localized name — it joins
`Fact_basis/maps/class_table.json`. (`pcall(UnitClass,…)` prepends `ok`, so the token is the *third* value; getting
that wrong yields the near-useless localized name. Already caught and fixed here.)

## Context matters more than a second task

A verdict is **true of the moment it ran**. Ideal is **two passes in different contexts** — e.g. one resting/idle,
one **in combat + mounted** (or in a form/stance). The pair separates "false here" from "always false" for
`combat`/`mounted`/`flying`/`stance:N`/`form:N`.

**But one pass is already worth landing** — most of the 63 flags aren't context-bound, and the stamp makes the
context-bound ones interpretable rather than ambiguous. Don't block on the second pass; land the first.

## Where the answers go (not your problem, for context)

Raw record → a map derives verdicts → `proof_mark` updates on `reference/candidates.json` → the **proven** set
graduates into `basis/conditionals.json`. That's the only path anything becomes fact in this slice. The map is the
macros bench's next build, once data exists.

## Standing limits — worth carrying into the record

- **A probe proves only what it ASKS.** The ask-list came from the wiki citation chain, so **the rim stays open** —
  the output is a proven set with an honest rim, never an enumeration.
- **Absence proves nothing.** Demonstrated in our own data: `@pettarget` is witnessed in this client's Lua
  (`ChatFrame.lua:1471`) and appears in **no wiki**.

## Highest-information rows (if anything gets cut, cut from the bottom)

| tier | rows | why |
|---|---|---|
| **1-backport-test** | 4 | **SOURCED** post-3.3.5a patch dates: `@cursor` **7.1.0 Legion** (Blizzard-cited), `pvpcombat` 7.3.0, `known` 10.0.2, `advflyable` 10.0.7. Here only if **backported** — and `@cursor` is a *confirmed, dated* backport already witnessed in CoA's own source, so the pattern has a proof. |
| **2-undated-test** | 9 | retail lists it, the ~2010 archive doesn't, **no patch annotation**. We genuinely don't know when it shipped. |
| **3-baseline** | 59 | archive-documented ⇒ expected present. An `UNSUPPORTED` here is a real finding. |
| **4-corroborate** | 4 | already source-corroborated; confirms behaviour. |

Full detail per row (method, era, patch, expectation): `probe_rows.json`. Nothing needs cutting — the whole set is
one pass.
