# macros — the CoA macro surface, look-up-able

_"Another slice of understanding CoA" (Battlewrath, 2026-07-17). The sheets model
(`Weak Auras/engine/Fact_basis/sheets`) applied to the macro surface: **pay the source-trace ONCE, emit generously
per DOMAIN, let every member self-report its own evidence** — so reasoning READS instead of re-deriving, and we stop
source-tracing one question at a time and missing the wider picture._

Founding read: **`operations/Macros.md`** (why this exists, the two channels, the rules, the rim). This file is the
folder's own map.

## The layout (two-tier menu, mirroring `addons/maps/census/`)

```
macros/
  tools/
    emit_macro_basis.py       the emitter — deterministic, one command, reads client source
    ingest_reference.py       external material -> reference/ (provenance-stamped)
  basis/                      FACT — sourced or proven. cite this.
    macros.routes.md          THE browse menu — start here, then open ONE domain
    domains.json              the top-domain catalog (counts + per-domain grain)
    commands.json             the typed verbs
    actions.json              the `type` vocabulary (/click + action buttons)
    conditionals.json         the option vocabulary — PROOF-PENDING, rim fully open
    api.json                  the macro C API + limits (limits CONFLICT)
    statedrivers.json         the 2nd consumer of the conditional vocabulary
    _meta.json                provenance anchor (sha256 per source archive) + counts
  reference/                  SECONDARY — external, provenance-stamped. NEVER cite as fact.
    README.md                 the grain statement — read before using anything here
    ascension-wiki-macros.*   the Ascension wiki page: raw wikitext + extracted CANDIDATES
```

**`basis/` vs `reference/` is the load-bearing split.** `basis/` answers *what is true*. `reference/` answers *what
should we ask*. A claim that lives only in `reference/` is a question, not an answer — see `reference/README.md`.

## GRAIN IS PER DOMAIN — they are not the same, and each file says its own

**Read this before citing anything here.** The single most important property of this basis is that its domains have
*different* epistemic standing:

| domain | grain | means |
|---|---|---|
| `commands` | **SOURCED-COMPLETE** | derived by join from the client's own Lua; cite freely |
| `actions` | **SOURCED-COMPLETE** | ditto |
| `conditionals` | **PROOF-PENDING — rim FULLY OPEN** | **zero attested.** cite nothing; the probe is the sole channel |
| `api` | runtime-attested × source constants | limits **conflict**; do not state a limit as fact |
| `statedrivers` | runtime-attested, **provenance OPEN** | live, but where they come from is unresolved |

## The one rule that governs this whole slice

**An agent's WoW knowledge is INADMISSIBLE here.** This client is not a pure 3.3.5a — it backports the Legion/BfA
`CompactUnitFrame` system, ships Dragonflight's `/kb` Quick Keybind, and carries Ascension's own hand-rolled
`[@cursor]`/`[@player]` ground-targeting. So recall is unreliable in **both** directions: a conditional can be ruled
neither *out* for being post-WotLK nor *in* for being WotLK-stock. Every fact here is joined from source or marked
proof-pending. Nothing is written from memory. (The standing convention, hard-won by the aggroHighlight saga: any
external lead — wowpedia, CurseForge, AI recall, forum posts — is an **unverified name** until confirmed live.)

## Why `conditionals.json` is empty, and why that's the honest answer

`SecureCmdOptionParse` is called **49× in `ChatFrame.lua` and defined nowhere in Lua**; the runtime census buckets it
`stock-capi`. The conditional vocabulary lives in the client binary — no source read reaches it.

The attested-usage seed (conditionals the client's *own* code uses — the census's grain) measured **zero**: no
`RegisterStateDriver` call sites in shipped code, no conditional-bearing macrotext. Not thin — zero. So the live
differential probe is not one of two channels, it is the **only** one.

`conditionals.json` carries the probe design and this standing limit: *a probe only ever proves conditionals someone
thought to ASK about — the output is a proven set with an honest rim, never an enumeration.* That line is the
difference between a fact basis and a nicer-looking guess.

**The ask-list now exists** (`reference/`, 2026-07-17): 24 candidates lifted from the Ascension wiki, on the rule
that *recall and secondary sources are inadmissible as a FACT source but admissible as a QUESTION source, because
the probe adjudicates.* The probe channel is **confirmed live** — the client has a built-in dev console
(`/luaconsole`, `/devconsole`), so the probe is interactive: no macro, no restart, resident API only.

**Before probing, read `reference/README.md`'s `@unit` ≠ `[flag]` split** — they are different mechanisms with
different proof methods, and the polarity matrix only applies to flags.

## Regenerate (deterministic, one command)

```
py macros\tools\emit_macro_basis.py
```

Depends on the patch-B study copy (`py addons\tools\extract_interface.py`) and, for bucket classification, the
runtime census (`addons/maps/census/runtime/globals.json`). The emitter reads the client through mpyq **in memory**;
`F:\games\Ascension_wow` is a **NO-EDIT space** — nothing here ever writes to it.

**Version anchor:** every emission stamps each source archive's sha256 in `_meta.json` (invariant 2). Fork moved ≠
cited sha → re-emit before trusting.

## The five rules the emitter encodes — each bought by a wrong answer first

Recorded so a rewrite doesn't re-earn them:

1. **Precedence MERGE, not top-archive.** `patch-enUS-3` looks like the winner and isn't a superset (`/lfg`, `/lfm`
   live only below it — the merge is why the count is 531, not 527). Archives are purely additive today, so
   precedence affects completeness only — but a value conflict gets **loud**.
2. **TWO token sources.** `GlobalStrings.lua` **plus** inline `SLASH_*` declarations in UI code. GlobalStrings alone
   loses every CoA-custom command.
3. **Conditional support is COMPUTED** per handler, never hand-listed. This is what caught the 5 *non-secure*
   commands that take conditionals.
4. **Resolve ALIASES.** `USE` = `CAST` by assignment; a naive scan reports `/use` as conditional-less — flatly false.
5. **Custom BEHAVIOUR falls out mechanically** off the census buckets — which is how `/castsequence` and
   `/castrandom` were found to carry the `[@cursor]` hack too, not just `/cast`.

**Three handler FORMS**, each learned by a command going missing: `inline` · `alias` · **named-ref**
(`= SomeHandler`) — and definitions are **not always at column 0** (`BDRAFT` nests in a block), so a body terminator
must match the definition's own indent.

## Two verifiers, because counting wrong is the failure mode here

- **The cross-total.** Handlers found to call `SecureCmdOptionParse` must equal raw call sites in source (49 = 49).
  The same owner-tracking bug produced a wrong count **twice** by hand; this is what catches it. If it ever fails,
  the conditional counts are wrong — don't trust them.
- **The holes report.** A token declared with no handler found, or a handler whose body couldn't be read, is
  **reported, never dropped**. Three commands went missing exactly that way once. Where a body is unresolved,
  `calls`/`custom_behaviour` are **blind** — absence of custom behaviour proves nothing there.

An empty holes list is a healthy holes list.
