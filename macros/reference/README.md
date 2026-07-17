# reference — external + local material. **NOT basis.**

_Provenance-stamped sources, kept separate from `../basis/`. Follows the repo's `ingest/reference/` pattern:
**trust STRUCTURE, not FIELDS.** Nothing in this folder is a fact about the CoA client._

**Counts live in the artifacts, never here.** `candidates.json` → `counts` / `sources`; `addon-macro-tools.json` →
per-addon. Prose that hardcodes a number goes stale silently — the exact failure the Materials fact sheet taught us.
This file carries **grain and rules**, which don't drift.

## The one rule

**Never cite `reference/` as `basis/`.** If a claim only appears here, it is a **question**, not an answer.

## Why the raws are TRACKED (don't prune them)

Settled by Battlewrath, 2026-07-17: *"Track them. Their reference material, not authority. Just as much as the
corpus is reference. They help fill curated intent."*

**Standing = the same as `corpus/`.** Reference material feeds **intent**; it is never authority. `corpus/` harvests
how people actually *build auras*; this harvests how people actually *write macros*. Neither is a fact about the
client — both are signal about what's worth building and what to ask.

**They earn their tracking on two counts, and the second is easy to miss:**

1. **The ask-list.** They're the only non-invented source for the probe's questions — the alternative was an agent's
   recall, which this slice rules inadmissible.
2. **Curated intent.** The worked examples (smart-heal fallback chains, mouseover healing, modifier swaps,
   cast-sequence openers) are *what players actually want a macro to do*. That's design input for the eventual
   guide — the same role a `corpus/patterns/` entry plays for auras.

**Why verbatim, and why committed** (the opposite call from the client extraction, deliberately): the client study
copy is **gitignored** because `extract_interface.py` can regenerate it exactly. A wiki fetch **cannot** be
regenerated — the page moves, and the revid moves with it. So the raw *is* the reproducibility: extraction
re-derives offline from the saved bytes, and a changed revid on `--fetch` prints **loud** instead of silently
re-writing history under us.

**Attribution:** third-party wiki content (fandom / wiki.gg, CC BY-SA). Every raw carries its URL + revid +
sha256 in `*.provenance.json`. Same redistribution caution `addons/refs_threat/` already raises.

## Why any of this is admissible

> **Recall and secondary sources are INADMISSIBLE as a FACT source
> but ADMISSIBLE as a QUESTION source — because the probe adjudicates.**
>
> A wrong candidate costs one probe row reading "unsupported".
> A wrong fact poisons the basis silently.

`basis/conditionals.json` carries a standing limit: *a probe only ever proves conditionals someone thought to ASK
about.* That limit needs an ask-list, and the only alternative was an agent's own WoW recall — which this slice
rules inadmissible. **This folder is where the ask-list comes from without anyone inventing it.**

## What's here, and how much each is worth

| source | standing |
|---|---|
| **the WA sheets** (joined, not copied) | **LOCAL + SOURCED** — `Fact_basis/sheets/domains.json` `baseUnitId`/`multiUnitId`, from the **installed fork's** `Types.lua`, on **this** client. The strongest witness here. |
| `addon-macro-tools.json` | the two installed macro addons — **code aimed at a client**. One notch above a wiki; still an author's belief. |
| `ascension-wiki-macros.*` | the server's own guide — but it **inherits** its conditional list from the retail wikis (see its Resources section). |
| `wowwiki-archive-*` | the old wowwiki, content ~2010. Documents spell **ranks** ⇒ WotLK/early-Cata; closest external match to a 3.3.5a base. |
| `wowpedia-*`, `warcraft-wiki-*` | retail — for **patch dating** and the **unit-token vocabulary**. |

Raws are saved **verbatim** with sha256 + revid; a changed revid on `--fetch` prints **loud**. The fetch is network
(not reproducible), so extraction re-derives from the saved copies offline by default.

## Local witnesses come first — and answer a different question

The sheets model exists so reasoning **reads** instead of re-derives, and a local sourced witness beats any external
doc. **But local sources are complementary, not a substitute** — stated precisely because the reverse mistake is
just as easy:

- The sheets carry **zero conditionals**. Most candidates are flags; WA has no macro-conditional surface at all.
- The sheets **omit `mouseover`** — not because it's absent, but because WA *watches* state rather than *casting*.
- The sheets carry **no patch dating** (`@cursor` → 7.1.0 is unreachable from them).
- Where they overlap (unit tokens) they are the **stronger** witness, and mark those `LOCAL-SOURCE-CORROBORATED`.

**WA *listing* a token corroborates it. WA *omitting* one proves nothing.** Its list is *what WA offers as a trigger
unit* — it even **adds** abstractions that are not client tokens (`group`, `grouppets`, `partypets`…) and must never
be read as macro targets.

## Already proven locally — cite, don't re-ask

`@nameplate` is **live-proven** (`corpus/patterns/guardian-health-tracker.md`, 2026-07-15): plate tokens resolve,
with a landed evidence pair. It's also **richer than a probe** — it carries the boundary (*token lifetime = plate
population, not model visibility*). The row survives only because **targeting** a plate from a macro is a different
question from **reading** one (retail says it can't be done; unverified here). See `local_proven` in
`candidates.json`.

## `@unit` ≠ `[flag]` — different mechanisms, different proof

- **`@unit`** — *hypothesis:* a **pass-through string**. The parser returns whatever follows `@`; support lives
  **downstream** (the handler's special-casing → `Custom_HandleTerrainClick`; unit resolution). Polarity does not
  apply — there is likely no `[no@cursor]`. **One control row settles it:** `[@banana]`.
- **`[flag]`** — actually **evaluated** by the C parser. This is the vocabulary question the polarity matrix is for.

**Three things collide on "cursor"** (see `two_mechanisms.the_cursor_collision`): `@cursor` = a ground **location**
(7.1.0, Blizzard-cited, hand-rolled on CoA); `@mouseover` = a **unit**; `[cursor]` = a **flag** for what the cursor
is *holding*. Three mechanisms, three proof methods, one word.

## The era signal runs on evidence, not absence

A `{{Patch}}` annotation **dates** a candidate — that's evidence. Where none exists, the honest label is
`retail-documented-only` = **UNDATED**; absence from a 2010 archive proves nothing. An earlier classifier called
that bucket "post-wotlk" and inferred history from absence — right for the dated rows *by luck, not method*.

## Regenerate

```
py macros\tools\ingest_reference.py            re-derive from saved raws (offline, deterministic)
py macros\tools\ingest_reference.py --fetch    re-pull from the network (revid change = LOUD)
py macros\tools\ingest_addon_reference.py      re-scan the installed macro addons
```

`completeness_check.incomplete` in `candidates.json` **must be empty** — it's the positive check that catches a
branch silently skipping a candidate's derivation (which happened, twice, while the run printed success).
