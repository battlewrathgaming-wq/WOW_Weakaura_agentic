# Engine

The self-contained aura engine: **inventory marks → export strings.** Input → Process → Output.

Started 2026-07-13, the day of the first external live proof of concept (the Tome of Ahn'kahet tracker landed correct
on a beta tester's client). Proven enough to migrate the settled pipeline into an actual logical structure, leaving the
lineage (`../plane/`, the template era) where it stands.

## The line (the one invariant)

Correctness is caught **once**, at docket formation.

```
ABOVE the line   reasoning · friendly expansion (friendly-intent → WA-literal)     ← friendly, fallible
════ THE GATE ═══ word-match: correctness caught → docket forms WA-literal ════════
BELOW the line   verified docket → expand → fill → bounce → codec                  ← mechanical, verified, trusts the docket
```

Nothing invented crosses. The sheets are source-authored only; the docket is WA-literal; only the docket's `id` carries
human character. (See memory: `adr-inventiveness-confined-to-contained-spaces`, `docket-wa-literal-preflight-gate`.)

## INPUT — consumed, not owned (produced upstream, the engine reads)

- **contract** — the WA truth (fields + domains). Built by `../wa_index/` (WA source → sheets → `contract.json`).
- **class-data** — identity + effect chain. `../../Outputs/spell_dbc/coa_spells.json` (DBC, the triggeredBy graph),
  `../../Input/*_talents.json` (the ability DB).
- **inventory** — per-class authoring docs: prose (meaning) + `[/]…[\]` marks (WA-literal dockets + code-wrapped payloads).

## PROCESS — the gears (the engine's own)

1. **gate** — pre-flight word-match: each mark token → `known-field` / `known-ability` / `user-input` / `malform`.
   Catches *before* the docket forms. Verdict is ephemeral (sticky only on malform). **← FIRST BUILD**
2. **generate** — marks → dockets, clustered by PID. Emits the gate verdict beside the mark + pure dockets into process.
3. **pipeline** (per docket) — expand → fill → bounce. *(migrating from `../plane/`)*
4. **bundle** — dockets → one group export string. *(migrating from `../plane/bundle.py`)*
5. **codec** — encode / decode. *(from `../weakaura_codec.py`)*

## OUTPUT

- **export strings** — per-class packs. Dockets are **transient exhaust** (generated → consumed → export lands →
  deleted). Durable = the inventory marks (source) + the export string (product).

## Catalogue — the durable learning

Working primitives + their distilled **failure-mode trails** (self-referential: the agent reasoning the next instance
reads them and avoids the failure). First tenant: the **proc-buff tracker** (Tome, live-proven).

---
*Name is provisional ("engine room") — rename freely; nothing here hardcodes the folder name yet.*
