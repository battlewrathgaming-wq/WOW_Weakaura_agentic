# Phase 1 — freeze the docket schema

**Goal:** ONE versioned JSON schema — the agent's (and generator's) entire
write surface. Everything downstream reads it; nothing downstream extends it.
Principles: P1, P10.

The docket is the v1 BOM evolved. plane/assemble.py already consumes
`boms/*.bom.json` (lanes, part refs, fills, conditions); the docket keeps that
spine and adds what autonomy needs: per-decision `why`, contract-facing fill
keys, and the slot/spell identity that lets receipts trace back to intent.

## Schema (per aura entry)

```json
{
  "slot":      {"mask": "necro_hud", "row": "tier1", "col": 3},
  "spell":     533236,
  "base":      "cooldown_button",
  "triggers":  [{"type": "spell", "event": "Cooldown Progress (Spell)",
                 "fill": {"spellName": 533236},
                 "why": "drive-from-ID, family match"}],
  "conditions":[{"check": {"trigger": 1, "var": "onCooldown", "op": "==", "value": 1},
                 "changes": [{"prop": "desaturate", "value": true}],
                 "why": "ability-local cooldown dim"}],
  "display":   {"region": "icon", "fill": {}},
  "load":      {"fill": {"use_class": true, "class": "NECROMANCER"}}
}
```

A docket file: `{docket_id, class, spec, schema_version, auras: [...]}`.

## Rules of the format

- `base` names a BASE_AURAS primitive (the authored frame). Fills are the ONLY
  free-value fields.
- Fill keys are contract option names (WA field names, dotted for nesting) —
  the same convention v1 apply_fills already speaks.
- Every entry that makes a choice carries `why` (consumed into fill_receipt,
  P7). Mechanical generators write mechanical whys ("cooldown 120s → major").
- Condition `check` uses the grammar's recursive AND/OR shape
  (COMPOSITION_GRAMMAR.md); vars must be contract `provides`.
- NOTHING in a docket is a raw WA table. The agent never writes WA's
  serialization forms — that's the filler/assembler's side of the
  provide-vs-handle line.

## Base primitives re-founded as AUTHORED dockets (not harvested tables)

BASE_AURAS primitives were harvested from the corpus — structure that leaked
in through the training-data door. Re-found them here as short REASONING
artifacts written in the docket schema: a `cooldown_button` is a docket whose
every ingredient cites source (icon region default + Cooldown Progress
default_state + one grammar condition), with a `why` per choice. The corpus's
role flips to CONFIRMATION — our authored primitive matches what players
converge on (e.g. rotation = 40% of corpus) — taste validated by the corpus,
never copied from it (P6, P11). Every aura is then built reasoning-first:
reasoning (docket) → conditional logic (grammar over sourced provides) →
assembly (mechanical drop into the source-derived skeleton, WA completes).

## Deliverables

- `plane_v2/docket.schema.json` — machine-checkable (jsonschema), versioned.
- The base-primitive dockets (`cooldown_button`, `buff_track`, …) — authored,
  source-cited, corpus-confirmed.
- A worked example docket (Corpse Explosion — the proven v1 subject) that the
  filler + assembler must reproduce byte-identically to v1's golden, proving
  BOM → docket continuity.

## Exit gate
Schema committed; the example docket validates against it; v1's golden
reproduced through the docket path; each base-primitive docket's ingredients
fully attributed to contract rows (zero corpus-sourced structure).
