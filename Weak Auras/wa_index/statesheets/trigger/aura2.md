# Trigger type: Aura  (`aura2`)

_1 events. input = you fill · provides = trigger outputs (conditions/subregions) · seed = forced on · gated = conditional._


## Aura  (`Aura`)
default state: `{"type": "aura2", "debuffType": "HELPFUL", "unit": "player"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| unit | input | catch | ['baseUnitId', 'multiUnitId'] | player |  |  |  |
| debuffType | input | catch | debuff_types | HELPFUL |  |  |  |
| auranames | input | catch |  |  |  |  | →True |
| auraspellids | input | catch |  |  |  |  | →False |
| namePattern_name | input | catch |  |  |  |  |  |
| ownOnly | input | catch |  |  |  |  |  |
| debuffClass | input | catch | debuff_class_types |  |  |  |  |
| ignoreAuraNames | input | catch |  |  |  |  |  |
| ignoreAuraSpellids | input | catch |  |  |  |  |  |
| match_count | input | resolve |  |  |  |  |  |
| perUnitMode | input | resolve | bufftrigger_2_per_unit_mode |  |  |  |  |
| combineMatches | input | resolve |  |  |  |  |  |
| autoclone | input | resolve |  |  |  |  |  |
| group_count | input | resolve |  |  |  |  |  |
| (options-layer; set on 0 of 319 corpus triggers) | input | resolve | ['Most remaining', 'Highest spell ID', 'Least remaining', 'Lowest spell ID'] |  |  |  |  |
| matchesShowOn | input | show | ['showOnActive', 'showOnMissing', 'showOnMatches', 'showAlways'] | showOnActive |  |  |  |
| unitExists | input | show |  |  |  |  |  |
| inverse | input | show |  |  |  |  |  |
| stacks | provides | read |  |  |  |  |  |
| rem | provides | read |  |  |  |  |  |
| duration | provides | read |  |  |  |  |  |
| fetchTooltip | provides | read |  |  |  |  |  |
| isStealable | provides | read |  |  |  |  |  |
| isBossDebuff | provides | read |  |  |  |  |  |
| isCastByPlayer | provides | read |  |  |  |  |  |
