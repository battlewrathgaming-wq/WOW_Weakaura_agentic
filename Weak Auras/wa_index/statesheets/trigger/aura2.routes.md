# aura2 - routing index
_Main (input) levers only. Open `aura2.json` for full handling. rule: `array`=multiEntry (value+operator as arrays) - `dom:X`=value-domain X (see domains.json)._

## Aura
| lever | type | rule |
|---|---|---|
| useUnit (Unit) | toggle |  |
| unit (Unit) | select |  |
| useSpecificUnit (Specific Unit) | toggle |  |
| specificUnit (Specific Unit) | input |  |
| useDebuffType (Aura Type) | toggle |  |
| debuffType (Aura Type) | select | dom:debuff_types |
| use_debuffClass (Debuff Type) | toggle |  |
| debuffClass (Debuff Type) | multiselect | dom:debuff_class_types |
| useName (Name(s)) | toggle |  |
| name1 (Aura Name) | input |  |
| useExactSpellId (Exact Spell ID(s)) | toggle |  |
| spellid1 (Spell ID) | input |  |
| useIgnoreName (Ignored Name(s)) | toggle |  |
| ignorename1 (Ignored Aura Name) | input |  |
| useIgnoreExactSpellId (Ignored Exact Spell ID(s)) | toggle |  |
| ignorespellid1 (Ignored Spell ID) | input |  |
| useNamePattern (Name Pattern Match) | toggle |  |
| namePattern_operator (Operator) | select | dom:string_operator_types |
| namePattern_name (Aura Name Pattern) | input |  |
| useStacks (Stack Count) | toggle |  |
| stacksOperator (Operator) | select | dom:operator_types |
| stacks (Stack Count) | input |  |
| useRem (Remaining Time) | toggle |  |
| remOperator (Operator) | select | dom:operator_types |
| rem (Remaining Time) | input |  |
| useTotal (Total Time) | toggle |  |
| totalOperator (Operator) | select | dom:operator_types |
| total (Total Time) | input |  |
| use_stealable (Is Stealable) | toggle |  |
| use_isBossDebuff (Is Boss Debuff) | toggle |  |
| use_castByPlayer (Cast by a Player Character) | toggle |  |
| ownOnly (Own Only) | toggle |  |
| fetchTooltip (Fetch Tooltip Information) | toggle |  |
| use_tooltip (Tooltip Pattern Match) | toggle |  |
| tooltip_operator (Operator) | select | dom:string_operator_types |
| tooltip (Tooltip Content) | input |  |
| use_tooltipValue (Tooltip Value) | toggle |  |
| tooltipValueNumber (Tooltip Value #) | select | dom:tooltip_count |
| tooltipValue_operator (Operator) | select | dom:operator_types |
| tooltipValue (Tooltip) | input |  |
| useAffected (Fetch Affected/Unaffected Names and Units) | toggle |  |
| fetchRole (Fetch Role Information) | toggle |  |
| fetchRaidMark (Fetch Raid Mark Information) | toggle |  |
| use_includePets (Include Pets) | toggle |  |
| includePets (Include Pets) | select | dom:include_pets_types |
| useActualSpec (Filter by Specialization) | toggle |  |
| actualSpec (Actual Spec) | multiselect |  |
| useGroupRole (Filter by Group Role) | toggle |  |
| group_role (Group Role) | multiselect | dom:role_types |
| useRaidRole (Filter by Raid Role) | toggle |  |
| raid_role (Raid Role) | multiselect | dom:raid_role_types |
| useClass (Filter by Class) | toggle |  |
| class (Class) | multiselect |  |
| useUnitName (Filter by Unit Name) | toggle |  |
| unitName (Filter by Unit Name) | input |  |
| useHostility (Filter by Hostility) | toggle |  |
| hostility (Hostility) | select | dom:hostility_types |
| useNpcId (Filter by Npc ID) | toggle |  |
| npcId (Npc ID) | input |  |
| ignoreSelf (Ignore Self) | toggle |  |
| ignoreDead (Ignore Dead) | toggle |  |
| ignoreDisconnected (Ignore Disconnected) | toggle |  |
| inRange (Ignore out of casting range) | toggle |  |
| ignoreInvisible (Ignore out of checking range) | toggle |  |
| useGroup_count (Unit Count) | toggle |  |
| group_countOperator (Operator) | select | dom:operator_types |
| group_count (Count) | input |  |
| use_matchesShowOn (Show On) | toggle |  |
| matchesShowOn (Show On) | select | dom:bufftrigger_2_progress_behavior_types |
| useMatch_count (Match Count) | toggle |  |
| match_countOperator (Operator) | select | dom:operator_types |
| match_count (Count) | input |  |
| useMatchPerUnit_count (Match Count per Unit) | toggle |  |
| matchPerUnit_countOperator (Operator) | select | dom:operator_types |
| matchPerUnit_count (Count) | input |  |
| showClones (Auto-Clone (Show All Matches)) | toggle |  |
| combinePerUnit (Combine Matches Per Unit) | toggle |  |
| use_perUnitMode (Show Matches for Units) | toggle |  |
| perUnitMode (Show Matches for) | select | dom:bufftrigger_2_per_unit_mode |
| use_combineMode (Preferred Match) | toggle |  |
| combineMode (Preferred Match) | select | dom:bufftrigger_2_preferred_match_types |
| unitExists (Show If Unit Does Not Exist) | toggle |  |
| auranames |  |  |
| auraspellids |  |  |
| autoclone |  |  |
| buffShowOn |  |  |
| combineMatches |  |  |
| count |  |  |
| countOperator |  |  |
| fullscan |  |  |
| groupclone |  |  |
| hideAlone |  |  |
| ignoreAuraNames |  |  |
| ignoreAuraSpellids |  |  |
| name |  |  |
| name_info |  |  |
| name_operator |  |  |
| names |  |  |
| spellId |  |  |
| spellIds |  |  |
| subcount |  |  |
| type |  |  |
| useCount |  |  |
| use_name |  |  |
| use_spellId |  |  |
