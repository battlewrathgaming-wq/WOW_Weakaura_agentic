# Trigger type: Aura  (`aura2`)

_1 events. input = you fill · provides = trigger outputs (conditions/subregions) · seed = forced on · gated = conditional._


## Aura  (`Aura`)
default state: `{"type": "aura2", "debuffType": "HELPFUL", "unit": "player"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| useUnit | input |  |  |  |  |  |  |
| unit | input |  |  |  |  |  |  |
| useSpecificUnit | input |  |  |  |  |  |  |
| specificUnit | input |  |  |  |  |  |  |
| useDebuffType | input |  |  |  |  |  |  |
| debuffType | input |  |  |  |  |  |  |
| use_debuffClass | input |  |  |  |  |  |  |
| debuffClass | input |  |  |  |  |  |  |
| useName | input |  |  |  |  |  | →True |
| name1 | input |  |  |  |  |  |  |
| useExactSpellId | input |  |  |  |  |  | →False |
| spellid1 | input |  |  |  |  |  |  |
| useIgnoreName | input |  |  |  |  |  |  |
| ignorename1 | input |  |  |  |  |  |  |
| useIgnoreExactSpellId | input |  |  |  |  |  |  |
| ignorespellid1 | input |  |  |  |  |  |  |
| useNamePattern | input |  |  |  |  |  |  |
| namePattern_operator | input |  |  |  |  |  |  |
| namePattern_name | input |  |  |  |  |  |  |
| useStacks | input |  |  |  |  |  |  |
| stacksOperator | input |  |  |  |  |  |  |
| stacks | input |  |  |  |  |  |  |
| useRem | input |  |  |  |  |  |  |
| remOperator | input |  |  |  |  |  |  |
| rem | input |  |  |  |  |  |  |
| useTotal | input |  |  |  |  |  |  |
| totalOperator | input |  |  |  |  |  |  |
| total | input |  |  |  |  |  |  |
| use_stealable | input |  |  |  |  |  |  |
| use_isBossDebuff | input |  |  |  |  |  |  |
| use_castByPlayer | input |  |  |  |  |  |  |
| ownOnly | input |  |  |  |  |  |  |
| fetchTooltip | input |  |  |  |  |  |  |
| use_tooltip | input |  |  |  |  |  |  |
| tooltip_operator | input |  |  |  |  |  |  |
| tooltip | input |  |  |  |  |  |  |
| use_tooltipValue | input |  |  |  |  |  |  |
| tooltipValueNumber | input |  |  |  |  |  |  |
| tooltipValue_operator | input |  |  |  |  |  |  |
| tooltipValue | input |  |  |  |  |  |  |
| useAffected | input |  |  |  |  |  |  |
| fetchRole | input |  |  |  |  |  |  |
| fetchRaidMark | input |  |  |  |  |  |  |
| use_includePets | input |  |  |  |  |  |  |
| includePets | input |  |  |  |  |  |  |
| useActualSpec | input |  |  |  |  |  |  |
| actualSpec | input |  |  |  |  |  |  |
| useGroupRole | input |  |  |  |  |  |  |
| group_role | input |  |  |  |  |  |  |
| useRaidRole | input |  |  |  |  |  |  |
| raid_role | input |  |  |  |  |  |  |
| useClass | input |  |  |  |  |  |  |
| class | input |  |  |  |  |  |  |
| useUnitName | input |  |  |  |  |  |  |
| unitName | input |  |  |  |  |  |  |
| useHostility | input |  |  |  |  |  |  |
| hostility | input |  |  |  |  |  |  |
| useNpcId | input |  |  |  |  |  |  |
| npcId | input |  |  |  |  |  |  |
| ignoreSelf | input |  |  |  |  |  |  |
| ignoreDead | input |  |  |  |  |  |  |
| ignoreDisconnected | input |  |  |  |  |  |  |
| inRange | input |  |  |  |  |  |  |
| ignoreInvisible | input |  |  |  |  |  |  |
| useGroup_count | input |  |  |  |  |  |  |
| group_countOperator | input |  |  |  |  |  |  |
| group_count | input |  |  |  |  |  |  |
| use_matchesShowOn | input |  |  |  |  |  |  |
| matchesShowOn | input |  |  |  |  |  |  |
| useMatch_count | input |  |  |  |  |  |  |
| match_countOperator | input |  |  |  |  |  |  |
| match_count | input |  |  |  |  |  |  |
| useMatchPerUnit_count | input |  |  |  |  |  |  |
| matchPerUnit_countOperator | input |  |  |  |  |  |  |
| matchPerUnit_count | input |  |  |  |  |  |  |
| showClones | input |  |  |  |  |  |  |
| combinePerUnit | input |  |  |  |  |  |  |
| use_perUnitMode | input |  |  |  |  |  |  |
| perUnitMode | input |  |  |  |  |  |  |
| use_combineMode | input |  |  |  |  |  |  |
| combineMode | input |  |  |  |  |  |  |
| unitExists | input |  |  |  |  |  |  |
| name | provides |  |  |  |  |  |  |
| icon | provides |  |  |  |  |  |  |
| stacks | provides |  |  |  |  |  |  |
| debuffClass | provides |  |  |  |  |  |  |
| duration | provides |  |  |  |  |  |  |
| expirationTime | provides |  |  |  |  |  |  |
| unitCaster | provides |  |  |  |  |  |  |
| spellId | provides |  |  |  |  |  |  |
| isStealable | provides |  |  |  |  |  |  |
| isBossDebuff | provides |  |  |  |  |  |  |
| isCastByPlayer | provides |  |  |  |  |  |  |
| progressType | provides |  |  |  |  |  |  |
