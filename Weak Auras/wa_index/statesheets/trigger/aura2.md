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
| debuffType | input |  | debuff_types |  |  |  |  |
| use_debuffClass | input |  |  |  |  |  |  |
| debuffClass | input |  | debuff_class_types |  |  |  |  |
| useName | input |  |  |  |  |  | →True |
| name1 | input |  |  |  |  |  |  |
| useExactSpellId | input |  |  |  |  |  | →False |
| spellid1 | input |  |  |  |  |  |  |
| useIgnoreName | input |  |  |  |  |  |  |
| ignorename1 | input |  |  |  |  |  |  |
| useIgnoreExactSpellId | input |  |  |  |  |  |  |
| ignorespellid1 | input |  |  |  |  |  |  |
| useNamePattern | input |  |  |  |  |  |  |
| namePattern_operator | input |  | string_operator_types |  |  |  |  |
| namePattern_name | input |  |  |  |  |  |  |
| useStacks | input |  |  |  |  |  |  |
| stacksOperator | input |  | operator_types |  |  |  |  |
| stacks | input |  |  |  |  |  |  |
| useRem | input |  |  |  |  |  |  |
| remOperator | input |  | operator_types |  |  |  |  |
| rem | input |  |  |  |  |  |  |
| useTotal | input |  |  |  |  |  |  |
| totalOperator | input |  | operator_types |  |  |  |  |
| total | input |  |  |  |  |  |  |
| use_stealable | input |  |  |  |  |  |  |
| use_isBossDebuff | input |  |  |  |  |  |  |
| use_castByPlayer | input |  |  |  |  |  |  |
| ownOnly | input |  |  |  |  |  |  |
| fetchTooltip | input |  |  |  |  |  |  |
| use_tooltip | input |  |  |  |  |  |  |
| tooltip_operator | input |  | string_operator_types |  |  |  |  |
| tooltip | input |  |  |  |  |  |  |
| use_tooltipValue | input |  |  |  |  |  |  |
| tooltipValueNumber | input |  | tooltip_count |  |  |  |  |
| tooltipValue_operator | input |  | operator_types |  |  |  |  |
| tooltipValue | input |  |  |  |  |  |  |
| useAffected | input |  |  |  |  |  |  |
| fetchRole | input |  |  |  |  |  |  |
| fetchRaidMark | input |  |  |  |  |  |  |
| use_includePets | input |  |  |  |  |  |  |
| includePets | input |  | include_pets_types |  |  |  |  |
| useActualSpec | input |  |  |  |  |  |  |
| actualSpec | input |  |  |  |  |  |  |
| useGroupRole | input |  |  |  |  |  |  |
| group_role | input |  | role_types |  |  |  |  |
| useRaidRole | input |  |  |  |  |  |  |
| raid_role | input |  | raid_role_types |  |  |  |  |
| useClass | input |  |  |  |  |  |  |
| class | input |  |  |  |  |  |  |
| useUnitName | input |  |  |  |  |  |  |
| unitName | input |  |  |  |  |  |  |
| useHostility | input |  |  |  |  |  |  |
| hostility | input |  | hostility_types |  |  |  |  |
| useNpcId | input |  |  |  |  |  |  |
| npcId | input |  |  |  |  |  |  |
| ignoreSelf | input |  |  |  |  |  |  |
| ignoreDead | input |  |  |  |  |  |  |
| ignoreDisconnected | input |  |  |  |  |  |  |
| inRange | input |  |  |  |  |  |  |
| ignoreInvisible | input |  |  |  |  |  |  |
| useGroup_count | input |  |  |  |  |  |  |
| group_countOperator | input |  | operator_types |  |  |  |  |
| group_count | input |  |  |  |  |  |  |
| use_matchesShowOn | input |  |  |  |  |  |  |
| matchesShowOn | input |  | bufftrigger_2_progress_behavior_types |  |  |  |  |
| useMatch_count | input |  |  |  |  |  |  |
| match_countOperator | input |  | operator_types |  |  |  |  |
| match_count | input |  |  |  |  |  |  |
| useMatchPerUnit_count | input |  |  |  |  |  |  |
| matchPerUnit_countOperator | input |  | operator_types |  |  |  |  |
| matchPerUnit_count | input |  |  |  |  |  |  |
| showClones | input |  |  |  |  |  |  |
| combinePerUnit | input |  |  |  |  |  |  |
| use_perUnitMode | input |  |  |  |  |  |  |
| perUnitMode | input |  | bufftrigger_2_per_unit_mode |  |  |  |  |
| use_combineMode | input |  |  |  |  |  |  |
| combineMode | input |  | bufftrigger_2_preferred_match_types |  |  |  |  |
| unitExists | input |  |  |  |  |  |  |
| auranames | runtime-read |  |  |  |  |  |  |
| auraspellids | runtime-read |  |  |  |  |  |  |
| autoclone | runtime-read |  |  |  |  |  |  |
| buffShowOn | runtime-read |  |  |  |  |  |  |
| combineMatches | runtime-read |  |  |  |  |  |  |
| count | runtime-read |  |  |  |  |  |  |
| countOperator | runtime-read |  |  |  |  |  |  |
| fullscan | runtime-read |  |  |  |  |  |  |
| groupclone | runtime-read |  |  |  |  |  |  |
| hideAlone | runtime-read |  |  |  |  |  |  |
| ignoreAuraNames | runtime-read |  |  |  |  |  |  |
| ignoreAuraSpellids | runtime-read |  |  |  |  |  |  |
| name | runtime-read |  |  |  |  |  |  |
| name_info | runtime-read |  |  |  |  |  |  |
| name_operator | runtime-read |  |  |  |  |  |  |
| names | runtime-read |  |  |  |  |  |  |
| spellId | runtime-read |  |  |  |  |  |  |
| spellIds | runtime-read |  |  |  |  |  |  |
| subcount | runtime-read |  |  |  |  |  |  |
| type | runtime-read |  |  |  |  |  |  |
| useCount | runtime-read |  |  |  |  |  |  |
| use_name | runtime-read |  |  |  |  |  |  |
| use_spellId | runtime-read |  |  |  |  |  |  |
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
