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
  applied/drop). _The bundle step owns the group wrapper — presentation, not per-member emit._
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
  seen in a real aura's load). `load.specialization` — on the load surface (sheet: `class`/`specialization`/`knowntalent`);
  the spec NAME comes from our class:spec axis (the dev-authored tree names, e.g. `Death`). The specialization value's
  exact stored form gets its `wa_load_verified` moment at the live confirm — same pattern the class token went through.

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
