# reference — external material. **NOT basis.**

_Provenance-stamped external sources, kept separate from `../basis/`. Follows the `ingest/reference/` pattern
already in the repo: **trust STRUCTURE, not FIELDS.** Nothing in this folder is a fact about the CoA client._

## The one rule

**Never cite `reference/` as `basis/`.** If a claim only appears here, it is a **question**, not an answer.

## Why an external source is allowed at all

The distinction that makes this safe, and the whole justification for the folder:

> **Recall and secondary sources are INADMISSIBLE as a FACT source
> but ADMISSIBLE as a QUESTION source — because the probe adjudicates.**
>
> A wrong candidate costs one probe row reading "unsupported".
> A wrong fact poisons the basis silently.

`basis/conditionals.json` carries a standing limit: *a probe only ever proves conditionals someone thought to ASK
about.* That limit needed an ask-list, and the only alternative source was an agent's own WoW recall — which this
slice rules inadmissible. **This folder is where the ask-list comes from without anyone inventing it.**

## What's here

| file | what | standing |
|---|---|---|
| `ascension-wiki-macros.wikitext` | the page's **raw wikitext, verbatim** | the artifact |
| `ascension-wiki-macros.json` | provenance + extracted candidates + grammar claims + the source join | **SECONDARY** |

**Provenance anchor:** `project-ascension.fandom.com/wiki/Macros`, pageid 4463, **revid 15818**, last edited
**2025-11-05** by `Tura0763`. Re-fetching with a changed revid prints a **loud** warning — the page moved, re-read
the diff before trusting anything derived from it.

## Why this wiki is a generator and not a witness

**Its own Resources section points at Wowpedia and wowwiki-archive for its "macro conditionals reference."** It
*inherits* its conditional list from retail documentation rather than verifying it against this client. That makes
its claims **exactly as unverified as agent recall** — same provenance, nicer formatting.

**Its absences prove nothing.** It's a beginner guide, not a reference. A conditional it omits is **un-asked**, not
unsupported. This is demonstrated mechanically rather than asserted: the source join found **`@pettarget`** — a
target token the client's own Lua special-cases (`ChatFrame.lua:1471`, `PET_ATTACK`) that **the wiki never
mentions**. One counter-example, found by the tool, on the first run.

## What the source join actually establishes

`corroborations` is the ONLY source witness the conditional vocabulary has anywhere on this client — and it is
narrow in a way worth stating precisely:

- It reaches **target tokens only** (`@cursor`, `@player`, `@focus`, `@target`, `@pettarget`), never flags like
  `[combat]`. **19 of the 24 candidates have no source witness of any kind.**
- It proves a **handler anticipates** the token (it compares the parser's returned `target` to a literal). It does
  **not** prove the parser validates it.
- `@cursor` is witnessed at three sites — `CAST`, `CASTRANDOM`, `CASTSEQUENCE` — independently agreeing with the
  `custom_behaviour` finding in `basis/commands.json`. Two separate derivations, same answer.

## The distinction this folder surfaced: `@unit` ≠ `[flag]`

Reading the witnesses closely splits the conditional domain in two, **with different proof methods** — conflating
them is the easiest way to write a confident wrong guide:

- **`@unit` / `target=unit`** — *hypothesis:* a **pass-through string**. The parser appears to return whatever
  follows `@`, and support lives **downstream** (the handler's special-casing → `Custom_HandleTerrainClick`; unit
  resolution). The polarity matrix likely doesn't apply — there is probably no `[no@cursor]`. **One probe row
  settles it:** `SecureCmdOptionParse("[@banana] X")` — if a nonsense unit comes back as `target="banana"`, `@` is
  pass-through and the vocabulary question doesn't apply to it at all.
- **`[flag]`** — actually **evaluated** by the C parser. *This* is the vocabulary question, and what the
  differential-polarity matrix in `basis/conditionals.json` is for.

## Regenerate

```
py macros\tools\ingest_reference.py            re-derive candidates from the saved raw (offline, deterministic)
py macros\tools\ingest_reference.py --fetch    re-pull from the network (revid change = LOUD)
```

The fetch is network, so it isn't reproducible — which is exactly why the raw is saved **verbatim** and stamped
(revid + sha256), and why candidate extraction re-derives from the saved copy by default.
