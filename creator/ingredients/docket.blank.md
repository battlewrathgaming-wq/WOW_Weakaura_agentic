# the blank docket — what a single slot item looks like

_The docket is the agent's input form: open boxes + select boxes. This is the WHOLE table structure — engrain it.
Every field below is read by a named gear (nothing else is read; anything extra word-matches at the gate or dies there).
The machine's contract: you declare INTENT-bearing content; WA's canon completes everything you don't say._

## The blank

```json
{
 "pid": "",
 "id": "",
 "uid": "",
 "regionType": "",
 "triggers": [
  {
   "type": "",
   "event": "",
   "declare": { }
  }
 ],
 "activation": { },
 "display": { },
 "subregions": [ ],
 "conditions": [ ],
 "load": { }
}
```

## Slot by slot

| slot | who reads it | what goes in | blank rules |
|---|---|---|---|
| `pid` | stage/pickup | the PACK id (`necromancer-death-target`) — a pack IS a group: 1 group docket + members share one pid | required; self-describing kebab |
| `id` | everyone (identity) | the human name — never validated, never styled | required |
| `uid` | identity | stable identity — **the inventory provides it; minted only when absent** | may be blank (one-off → mint) |
| `regionType` | gate (word-match) → region | `icon` / `aurabar` / `dynamicgroup` / … — see the region files | required; groups use `dynamicgroup` |
| `triggers[].type` + `event` | gate (surface lookup) | the trigger surface (`aura2` + `Aura`) — see the trigger files | required per trigger |
| `triggers[].declare` | gate (vocab → **liveness** → domain → corpus) → fill (verbatim) | the WA-literal read-form fields — LIVE keys only (the menu never lists a dead one) | empty = canon defaults |
| `activation` | fill | trigger combination: `disjunctive`, `activeTriggerMode`, `customTriggerLogic` | omit = WA defaults (all / first active) |
| `display` | fill (copies to top level) | region options declared positively (`desaturate`, `grow`…) — see the region file | omit = canon defaults |
| `subregions` | fill | `[{"type": "…", …props}]` — text/glow/border; canon completes each | omit = none |
| `conditions` | fill | `[{"check": {trigger, variable, op, value}, "changes": {prop: value}}]` — see conditions.md | omit = none |
| `load` | gate (soft) → fill (verbatim) | the WA-literal stored forms — **shaped from meaning by populate** (arg_shapes); hand-authoring? follow load.md's forms exactly (the `use_<name>` gate law) | omit = loads always |

## A real minimal one (live-proven)

```json
{
 "pid": "necromancer-oneoff",
 "id": "Festering Decay - missing",
 "uid": "coaNecOneoffFDMiss",
 "regionType": "icon",
 "triggers": [
  { "type": "aura2", "event": "Aura",
    "declare": { "unit": "target", "debuffType": "HARMFUL", "ownOnly": true,
                 "useName": true, "auranames": ["806324"],
                 "use_matchesShowOn": true, "matchesShowOn": "showOnMissing" } }
 ],
 "display": { "desaturate": true },
 "load": { "use_class": false, "class": { "multi": { "NECROMANCER": true } } }
}
```
Eleven declared decisions → a 30+-field working aura. Everything not written here, WA wrote.
