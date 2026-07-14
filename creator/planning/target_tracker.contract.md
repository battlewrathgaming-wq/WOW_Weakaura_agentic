# Target tracker — the bucket contract

_The first bucket contract: the emitter's basis. Select decides who's in (over the resolved axes); emit says what each
member becomes (WA-literal, grounded in `Fact_basis/sheets/trigger/aura2.json` + the proven docket form). Nothing here is
invented: every emit token word-matches a known source, and the values below were pulled by executed scripts
(`pull_target_tracker.py`), not asserted._

## The sentence (from buckets.md)
Your kept-up things on the enemy — *"for my target, do they have it?"* One icon per DoT/bane of yours, in a dynamic
group, on your target. unit=target deliberately flattens multi-dot (accepted; the ambient tab-prompt is the only loss).

## aura_target — what a member becomes
- **Region:** `icon` — one per member, drive-from-ID (auto icon).
- **Arrangement:** the pack's icons grouped; dynamic-group presentation is the settled ship form (grow/shrink as
  applied/drop). _Corrected by source trace: a pack **IS** a group — pickup demands exactly one **group docket**
  (`regionType: dynamicgroup`) beside the members, and bundle wraps `{group, children}`. The group is an authored
  document the contract emits (`emit_group`), form grounded in `plane/bundle.py` (id/regionType/uid + optional
  arrangement; canon defaults for v1 — users arrange). Stage reads `_authored/` **flat**._
- **Mechanism:** aura2 (BuffTrigger2), the buff-window reader.

## select — who's in (query over `resolved.json` axes + edges)
```
target:       enemy | both
persistence:  window
EXCLUDE control-only:  auras ⊆ CC set (stun/root/snare/silence/confuse/fear/taunt/transform/pacify/disarm/charm)
EXCLUDE builder:       trigger chain (≤2 deep) references energize / gen-shape customs {175, 184}
flavour tag:  DoT (any periodic aura) · bane (rest)   — same tracker, tag is metadata
dedupe:       by family name (match family, not rank)
```
Rules earned by eyeball on Necro/Death: `transform`→CC (Ghoulify), resource-gain→builder (Crypt Swarm, tick→energize).

## emit — the docket per member (WA-literal, slim footprint)
Proven container (`_authored/tome_of_ahnkahet.docket.json` form; declare = read-form; canon completes):
```json
{
 "pid": "<class>-<spec>-target",
 "id": "<Family Name>",
 "uid": "<provided by inventory>",
 "regionType": "icon",
 "triggers": [
  {
   "type": "aura2",
   "event": "Aura",
   "declare": {
    "unit": "target",
    "debuffType": "HARMFUL",
    "ownOnly": true,
    "spellIds": ["<family representative id>"]
   }
  }
 ],
 "load": { "class": "<API TOKEN>", "specialization": "<SPEC>" }
}
```
Grounding, token by token (aura2 sheet):
- `unit: target` — sheet input `unit` (our delta from canon default `player`).
- `debuffType: HARMFUL` — sheet input `debuffType`, domain `debuff_types` (delta from canon `HELPFUL`).
- `ownOnly: true` — sheet input `ownOnly`: *my* debuff, not another Necro's.
- `spellIds: [id]` — the drive-from-ID family catch (sheet `rank_resolution`: ID-in-names catches ALL ranks; the COA
  idiom). NOT `useExactSpellId` (pins one rank — policy off).
- show-on-active is canon default (`matchesShowOn`) — no declare needed; no target / no debuff → hidden. Correct.
- `load.class` — the game API token from `Fact_basis/maps/class_table.json` (NECROMANCER: `wa_load_verified: true`,
  seen in a real aura's load).
- `load.specialization` — **settled from the fork's own source** (client `WeakAuras/Prototypes.lua:1075`): Ascension wired
  COA specs natively into WA's load — `type=multiselect, values=specialization_types, test=WeakAuras.IsSpecActive(i)`,
  domain built per-class at runtime (`SpecializationUtil.GetSpecializationInfo(i)`, event
  `ASCENSION_CA_SPECIALIZATION_ACTIVE_ID_CHANGED`). **Stored form = the spec INDEX `i`** (multiselect key); the name is
  display only. Spec names are API-sourced fact (the scrape); the one residual datum is each class's index *order* —
  a COADump capture on that class's character (Necro's lands at the live confirm; `specialization_types` is precisely
  one of the dangling value-domains COADump exists to resolve).

## The first pull — NECROMANCER Death (final membership, 7)
| flavour | family | rep id | dur / cd | note |
|---|---|---|---|---|
| DoT | Blight | 500217 | 20s / 0 | multi-dot (dur ≫ cd) |
| DoT | Flesh to Worms | 500338 | 18s / 0 | |
| DoT | Harvest Plague | 500968 | 18–24s / 0 | periodic_leech |
| DoT | Lichplague | 802132 | 18s / 30s | single-target burn (dur ≈ cd) |
| DoT | Plague of Undeath | 501940 | 20s / 0 | + heal-cut rider (DoT wins the why) |
| bane | Festering Decay | 806324 | 15s / 0 | amp (damage-taken up) |
| bane | Parasites | 560729 | 8s / 0 | payload scripted (dummy) — tracking surface fine |

Excluded, visibly: Crypt Swarm (builder — tick→energize), Ghoulify (CC — fear+transform).

## Open at build time
- The dynamic-group wrapper in the bundle (presentation).
- `uid`s come from the class inventory (minted only if absent — the inventory owns them).
- Live confirm: one member through docket → gate → wrap → import → in-game before widening.
