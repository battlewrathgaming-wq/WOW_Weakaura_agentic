# region: dynamicgroup — the self-arranging container

_Members appear/disappear and the group re-flows. A pack IS a group (pickup demands exactly one group docket per PID;
bundle wraps `{group, children}`). Fact source: `sheets/display/dynamicgroup.json` (32 levers + the coupling table).
Proven: the Target tracker (icons appear per active DoT/bane) and the venomancer pack, both live-imported clean._

## The proven core

```json
{ "pid": "<pack>", "id": "<Name>", "uid": "<uid>", "regionType": "dynamicgroup", "load": { ... } }
```
Canon defaults arrange it; users re-arrange in WA's UI (localize, don't replace — works OOTB, bends to taste).

## Arrangement ingredients (authored only when intent-bearing)

| ingredient | what it does | good for |
|---|---|---|
| `grow` | direction members flow (DOWN/UP/LEFT/RIGHT/HORIZONTAL/VERTICAL/GRID/CIRCLE) | bars stack DOWN; icon rows go HORIZONTAL |
| `align` | cross-axis alignment | keeping a row's icons on one baseline |
| `gridType` + `gridWidth` | grid fill order + width | icon grids (payoff/availability walls) |
| `selfPoint` | the member anchor — **COUPLED to grow/align/gridType** | never author alone: expand injects the paired value from the contract's coupling table when you author a grow |
| `sort` | member order | stable order = muscle memory; leave default unless the ask names an order |
| `space` / `stagger` | member spacing / diagonal offset | breathing room; stagger for cascade looks |
| `limit` | max members shown | top-N displays (busiest trackers) |
| `animate` | re-flow animation | taste; default off is calmer |
| `anchorPerUnit` / `useAnchorPerUnit` | sub-group per unit | multi-unit displays (group frames territory — usually not ours) |
| `alpha` | whole-group opacity | ambient packs (visible but quiet) |

## Composition notes

- **The group owns placement** — members' own anchor fields are irrelevant inside it; don't author both.
- Members with `showClones` multiply INSIDE the group naturally (one catch → several tiles).
- `condition_change_targets` on the group itself is EMPTY (sheet fact) — conditions act on members, not the container.
- The group is a first-class aura: same docket chain, same gate, same canon (bundle constructs nothing).
