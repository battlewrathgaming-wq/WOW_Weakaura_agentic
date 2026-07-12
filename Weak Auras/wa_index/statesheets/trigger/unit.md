# Trigger type: Player/Unit Info  (`unit`)

_20 events. input = you fill · provides = trigger outputs (conditions/subregions) · seed = forced on · gated = conditional._


## Cast  (`Cast`)
default state: `{"type": "unit", "event": "Cast", "use_unit": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| unit | input | dropdown |  |  | ✓ |  |  |
| spellNames | input | reference |  |  |  | ✓ |  |
| spellIds | input | reference |  |  |  | ✓ |  |
| spell | input | reference |  |  |  |  |  |
| castType | input | dropdown | {'cast': 'Cast', 'channel': 'Channel (Spell)'} |  |  | ✓ |  |
| interruptible | input | dropdown |  |  |  | ✓ |  |
| remaining | input | value |  |  |  | ✓ |  |
| unitCharacteristicsHeader | input | ui |  |  |  |  |  |
| npcId | input | reference |  |  |  | ✓ |  |
| class | input | dropdown |  |  |  | ✓ |  |
| role | input | dropdown | {'caster': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Ranged', 'healer': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t ', 'melee': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Melee', 'tank': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t '} |  |  | ✓ |  |
| raid_role | input | dropdown | {'MAINASSIST': '|TInterface\\GroupFrame\\UI-Group-mainassistIcon:16:16|t ', 'MAINTANK': '|TInterface\\GroupFrame\\UI-Group-maintankIcon:16:16|t ', 'NONE': 'Other'} |  |  | ✓ |  |
| raidMarkIndex | input | dropdown |  |  |  |  |  |
| nameplateType | input | dropdown | {'friendly': 'Friendly', 'hostile': 'Hostile'} |  |  |  |  |
| sourceUnit | input | dropdown |  |  |  | ✓ |  |
| sourceName | input | reference |  |  |  | ✓ |  |
| sourceRealm | input | reference |  |  |  | ✓ |  |
| sourceNameRealm | input | reference |  |  |  | ✓ |  |
| destUnit | input | dropdown |  |  |  | ✓ |  |
| destName | input | reference |  |  |  | ✓ |  |
| destRealm | input | reference |  |  |  | ✓ |  |
| destNameRealm | input | reference |  |  |  | ✓ |  |
| miscellaneousHeader | input | ui |  |  |  |  |  |
| showLatency | input | toggle |  |  |  | ✓ |  |
| includePets | input | dropdown | {'PetsOnly': 'Pets only', 'PlayersAndPets': 'Players and Pets'} |  |  | ✓ |  |
| ignoreSelf | input | toggle |  |  |  | ✓ |  |
| onUpdateUnitTarget | input | toggle |  |  |  | ✓ |  |
| inverse | input | toggle |  |  |  |  |  |
| spellId | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| duration | provides | state |  |  |  |  |  |
| expirationTime | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| inverse | provides | toggle |  |  |  |  |  |
| autoHide | provides | state |  |  |  | ✓ |  |
| raidMark | provides | state |  |  |  |  |  |

## Character Stats  (`Character Stats`)
default state: `{"type": "unit", "event": "Character Stats"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| primaryStatsHeader | input | ui |  |  |  |  |  |
| strength | input | value |  |  |  |  |  |
| agility | input | value |  |  |  |  |  |
| stamina | input | value |  |  |  |  |  |
| intellect | input | value |  |  |  |  |  |
| spirit | input | value |  |  |  |  |  |
| secondaryStatsHeader | input | ui |  |  |  |  |  |
| criticalrating | input | value |  |  |  |  |  |
| criticalpercent | input | value |  |  |  |  |  |
| hitrating | input | value |  |  |  |  |  |
| hitpercent | input | value |  |  |  |  |  |
| hasterating | input | value |  |  |  |  |  |
| hastepercent | input | value |  |  |  |  |  |
| expertiserating | input | value |  |  |  |  |  |
| expertisebonus | input | value |  |  |  |  |  |
| armorpenrating | input | value |  |  |  |  |  |
| armorpenpercent | input | value |  |  |  |  |  |
| spellpenpercent | input | value |  |  |  |  |  |
| resiliencerating | input | value |  |  |  |  |  |
| resiliencepercent | input | value |  |  |  |  |  |
| attackpower | input | value |  |  |  |  |  |
| spellpower | input | value |  |  |  |  |  |
| rangedattackpower | input | value |  |  |  |  |  |
| resistanceHeader | input | ui |  |  |  |  |  |
| resistancefire | input | value |  |  |  |  |  |
| resistancenature | input | value |  |  |  |  |  |
| resistancefrost | input | value |  |  |  |  |  |
| resistanceshadow | input | value |  |  |  |  |  |
| resistancearcane | input | value |  |  |  |  |  |
| tertiaryStatsHeader | input | ui |  |  |  |  |  |
| moveSpeed | input | toggle |  |  |  |  |  |
| movespeedpercent | input | value |  |  |  |  |  |
| defensiveStatsHeader | input | ui |  |  |  |  |  |
| defense | input | value |  |  |  |  |  |
| defensevalue | input | value |  |  |  |  |  |
| defensepercent | input | value |  |  |  |  |  |
| dodgerating | input | value |  |  |  |  |  |
| dodgepercent | input | value |  |  |  |  |  |
| parryrating | input | value |  |  |  |  |  |
| parrypercent | input | value |  |  |  |  |  |
| blockpercent | input | value |  |  |  |  |  |
| blockvalue | input | value |  |  |  |  |  |
| armorrating | input | value |  |  |  |  |  |
| armorpercent | input | value |  |  |  |  |  |
| avoidancetotalpercent | input | value |  |  |  |  |  |

## Class and Specialization  (`Class/Spec`)
default state: `{"type": "unit", "event": "Class/Spec"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| specId | input | dropdown |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |

## Conditions  (`Conditions`)
default state: `{"type": "unit", "event": "Conditions"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| alwaystrue | input | dropdown |  |  |  |  |  |
| incombat | input | dropdown |  |  |  |  |  |
| pvpflagged | input | dropdown |  |  |  |  |  |
| alive | input | dropdown |  |  |  |  |  |
| vehicle | input | dropdown |  |  |  |  |  |
| resting | input | dropdown |  |  |  |  |  |
| mounted | input | dropdown |  |  |  |  |  |
| HasPet | input | dropdown |  |  |  |  |  |
| ismoving | input | dropdown |  |  |  |  |  |
| afk | input | dropdown |  |  |  |  |  |
| ingroup | input | dropdown | {'group': 'In Party', 'raid': 'In Raid', 'solo': 'Not in Group'} |  |  |  |  |
| ruleset | input | dropdown | {'highrisk': {}, 'one': 'None', 'pve': {}, 'pvp': {}} |  |  |  |  |
| instance_size | input | dropdown | {'arena': 'Arena', 'fortyman': '40 Man Raid', 'none': 'No Instance', 'party': '5 Man Dungeon', 'pvp': 'Battleground', 'ten': '10 Man Raid', 'twenty': '20 Man Raid', 'twentyfive': '25 Man Raid'} |  |  |  |  |
| instance_difficulty | input | dropdown | {'ascended': 'Ascended', 'heroic': {}, 'mythic': 'Mythic', 'none': 'None', 'normal': {}} |  |  |  |  |

## Crowd Controlled  (`Crowd Controlled`)
default state: `{"type": "unit", "event": "Crowd Controlled"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| controlled | input | dropdown |  |  |  |  |  |

## Currency  (`Currency`)
default state: `{"type": "unit", "event": "Currency", "use_currencyId": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| currencyId | input | value |  |  | ✓ |  |  |
| value | input | value |  |  |  |  |  |
| totalEarned | input | value |  |  |  |  |  |
| description | input | reference |  |  |  |  |  |
| discovered | input | dropdown |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Death Knight Rune  (`Death Knight Rune`)
default state: `{"type": "unit", "event": "Death Knight Rune", "use_genericShowOn": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| rune | input | dropdown | ['Blood Rune #1', 'Blood Rune #2', 'Unholy Rune #1', 'Unholy Rune #2', 'Frost Rune #1', 'Frost Rune #2'] |  |  |  |  |
| isDeathRune | input | dropdown |  |  |  | ✓ |  |
| remaining | input | value |  |  |  | ✓ |  |
| genericShowOn | input | dropdown | {'showAlways': 'Always', 'showOnCooldown': 'On Cooldown', 'showOnReady': 'Not on Cooldown'} |  | ✓ | ✓ |  |
| runesCount | input | value |  |  |  | ✓ |  |
| bloodRunes | input | value |  |  |  | ✓ |  |
| frostRunes | input | value |  |  |  | ✓ |  |
| unholyRunes | input | value |  |  |  | ✓ |  |
| includeDeathRunes | input | toggle |  |  |  | ✓ |  |
| onCooldown | internal | state |  |  |  | ✓ |  |

## Player Experience  (`Experience`)
default state: `{"type": "unit", "event": "Experience"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| level | input | value |  |  |  |  |  |
| currentXP | input | value |  |  |  |  |  |
| totalXP | input | value |  |  |  |  |  |
| value | input | value |  |  |  |  |  |
| total | input | value |  |  |  |  |  |
| percentXP | input | value |  |  |  |  |  |
| restedExperienceHeader | input | ui |  |  |  |  |  |
| showRested | input | toggle |  |  |  |  |  |
| restedXP | input | value |  |  |  |  |  |
| percentrested | input | value |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |

## Faction Reputation  (`Faction Reputation`)
default state: `{"type": "unit", "event": "Faction Reputation", "use_factionID": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| watched | input | toggle |  |  |  |  |  |
| factionID | input | dropdown |  |  | ✓ | ✓ |  |
| name | input | reference |  |  |  |  |  |
| value | input | value |  |  |  |  |  |
| total | input | value |  |  |  |  |  |
| percentRep | input | value |  |  |  |  |  |
| standing | input | reference |  |  |  |  |  |
| standingId | input | dropdown |  |  |  |  |  |
| capped | input | dropdown |  |  |  |  |  |
| atWar | input | dropdown |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |

## Health  (`Health`)
default state: `{"type": "unit", "event": "Health", "use_unit": true, "use_absorbMode": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| unit | input | dropdown |  |  | ✓ |  |  |
| health | input | value |  |  |  |  |  |
| percenthealth | input | value |  |  |  |  |  |
| deficit | input | value |  |  |  |  |  |
| maxhealth | input | value |  |  |  |  |  |
| showAbsorb | input | toggle |  |  |  |  |  |
| absorbMode | input | dropdown | {'OVERLAY_FROM_END': 'Attach to End', 'OVERLAY_FROM_START': 'Attach to Start'} |  | ✓ | ✓ |  |
| absorb | input | value |  |  |  | ✓ |  |
| unitCharacteristicsHeader | input | ui |  |  |  |  |  |
| name | input | state |  |  |  |  |  |
| realm | input | reference |  |  |  |  |  |
| namerealm | input | reference |  |  |  |  |  |
| npcId | input | reference |  |  |  |  |  |
| class | input | dropdown |  |  |  |  |  |
| specId | input | dropdown |  |  |  | ✓ |  |
| role | input | dropdown | {'caster': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Ranged', 'healer': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t ', 'melee': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Melee', 'tank': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t '} |  |  | ✓ |  |
| raid_role | input | dropdown | {'MAINASSIST': '|TInterface\\GroupFrame\\UI-Group-mainassistIcon:16:16|t ', 'MAINTANK': '|TInterface\\GroupFrame\\UI-Group-maintankIcon:16:16|t ', 'NONE': 'Other'} |  |  | ✓ |  |
| raidMarkIndex | input | dropdown |  |  |  |  |  |
| miscellaneousHeader | input | ui |  |  |  | ✓ |  |
| includePets | input | dropdown | {'PetsOnly': 'Pets only', 'PlayersAndPets': 'Players and Pets'} |  |  | ✓ |  |
| ignoreSelf | input | toggle |  |  |  | ✓ |  |
| ignoreDead | input | toggle |  |  |  | ✓ |  |
| ignoreDisconnected | input | toggle |  |  |  | ✓ |  |
| inRange | input | toggle |  |  |  | ✓ |  |
| nameplateType | input | dropdown | {'friendly': 'Friendly', 'hostile': 'Hostile'} |  |  |  |  |
| value | provides | state |  |  |  |  |  |
| total | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| raidMark | provides | state |  |  |  |  |  |
| name | internal | state |  |  |  |  |  |

## Location  (`Location`)
default state: `{"type": "unit", "event": "Location"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| zoneIds | input | reference |  |  |  |  |  |
| zone | input | reference |  |  |  |  |  |
| subzone | input | reference |  |  |  |  |  |
| instanceHeader | input | ui |  |  |  |  |  |
| instanceSize | input | dropdown | {'arena': 'Arena', 'fortyman': '40 Man Raid', 'none': 'No Instance', 'party': '5 Man Dungeon', 'pvp': 'Battleground', 'ten': '10 Man Raid', 'twenty': '20 Man Raid', 'twentyfive': '25 Man Raid'} |  |  |  |  |
| instanceDifficulty | input | dropdown | {'ascended': 'Ascended', 'heroic': {}, 'mythic': 'Mythic', 'none': 'None', 'normal': {}} |  |  |  |  |
| zoneId | provides | state |  |  |  |  |  |
| instance | provides | state |  |  |  |  |  |

## Player Money  (`Money`)
default state: `{"type": "unit", "event": "Money"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| money | input | value |  |  |  |  |  |
| gold | input | value |  |  |  |  |  |
| silver | input | value |  |  |  |  |  |
| copper | input | value |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Pet  (`Pet Behavior`)
default state: `{"type": "unit", "event": "Pet Behavior"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| behavior | input | dropdown | {'aggressive': {}, 'defensive': {}, 'passive': {}} |  |  |  |  |
| inverse | input | toggle |  |  |  | ✓ |  |
| icon | provides | state |  |  |  |  |  |

## Power  (`Power`)
default state: `{"type": "unit", "event": "Power", "use_unit": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| unit | input | dropdown |  |  | ✓ |  |  |
| powertype | input | dropdown |  |  |  |  |  |
| requirePowerType | input | toggle |  |  |  | ✓ |  |
| showCost | input | toggle |  |  |  | ✓ |  |
| power | input | value |  |  |  |  |  |
| percentpower | input | value |  |  |  |  |  |
| deficit | input | value |  |  |  |  |  |
| maxpower | input | value |  |  |  |  |  |
| name | input | reference |  |  |  |  |  |
| realm | input | reference |  |  |  |  |  |
| unitCharacteristicsHeader | input | ui |  |  |  |  |  |
| namerealm | input | reference |  |  |  |  |  |
| npcId | input | reference |  |  |  | ✓ |  |
| class | input | dropdown |  |  |  |  |  |
| specId | input | dropdown |  |  |  | ✓ |  |
| role | input | dropdown | {'caster': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Ranged', 'healer': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t ', 'melee': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Melee', 'tank': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t '} |  |  | ✓ |  |
| raid_role | input | dropdown | {'MAINASSIST': '|TInterface\\GroupFrame\\UI-Group-mainassistIcon:16:16|t ', 'MAINTANK': '|TInterface\\GroupFrame\\UI-Group-maintankIcon:16:16|t ', 'NONE': 'Other'} |  |  | ✓ |  |
| raidMarkIndex | input | dropdown |  |  |  |  |  |
| miscellaneousHeader | input | ui |  |  |  | ✓ |  |
| includePets | input | dropdown | {'PetsOnly': 'Pets only', 'PlayersAndPets': 'Players and Pets'} |  |  | ✓ |  |
| ignoreSelf | input | toggle |  |  |  | ✓ |  |
| ignoreDead | input | toggle |  |  |  | ✓ |  |
| ignoreDisconnected | input | toggle |  |  |  | ✓ |  |
| inRange | input | toggle |  |  |  | ✓ |  |
| nameplateType | input | dropdown | {'friendly': 'Friendly', 'hostile': 'Hostile'} |  |  | ✓ |  |
| value | provides | state |  |  |  |  |  |
| total | provides | state |  |  |  |  |  |
| stacks | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| raidMark | provides | state |  |  |  |  |  |

## Range Check  (`Range Check`)
default state: `{"type": "unit", "event": "Range Check", "use_unit": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| note | input | ui |  |  |  |  |  |
| unit | input | dropdown |  |  | ✓ |  |  |
| minRange | input | value |  |  |  |  |  |
| maxRange | input | value |  |  |  |  |  |
| range | input | value |  |  |  |  |  |

## Stance/Form/Aura  (`Stance/Form/Aura`)
default state: `{"type": "unit", "event": "Stance/Form/Aura"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| note | input | ui |  |  |  |  |  |
| form | input | dropdown |  |  |  |  |  |
| inverse | input | toggle |  |  |  | ✓ |  |

## Swing Timer  (`Swing Timer`)
default state: `{"type": "unit", "event": "Swing Timer", "use_hand": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| note | input | ui |  |  |  |  |  |
| hand | input | dropdown | {'main': {}, 'off': {}, 'ranged': {}} |  | ✓ |  |  |
| remaining | input | value |  |  |  | ✓ |  |
| inverse | input | toggle |  |  |  |  |  |
| duration | provides | state |  |  |  |  |  |
| expirationTime | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Talent Known  (`Talent Known`)
default state: `{"type": "unit", "event": "Talent Known", "use_spellName": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| spellName | input | reference |  |  | ✓ |  |  |
| inverse | input | toggle |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |

## Threat Situation  (`Threat Situation`)
default state: `{"type": "unit", "event": "Threat Situation", "use_unit": true, "unit": "target"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| unit | input | dropdown |  | target | ✓ |  |  |
| status | input | dropdown | {'-1': 'Not On Threat Table', '0': '|cFFB0B0B0Lower Than Tank|r', '1': '|cFFFFFF77Higher Than Tank|r', '2': '|cFFFF9900Tanking But Not Highest|r', '3': '|cFFFF0000Tanking And Highest|r'} |  |  |  |  |
| aggro | input | dropdown |  |  |  |  |  |
| threatpct | input | value |  |  |  | ✓ |  |
| rawthreatpct | input | value |  |  |  | ✓ |  |
| threatvalue | input | value |  |  |  | ✓ |  |
| unitCharacteristicsHeader | input | ui |  |  |  |  |  |
| name | input | reference |  |  |  |  |  |
| npcId | input | reference |  |  |  |  |  |
| value | provides | state |  |  |  |  |  |
| total | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |

## Unit Characteristics  (`Unit Characteristics`)
default state: `{"type": "unit", "event": "Unit Characteristics", "use_unit": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| unit | input | dropdown |  |  | ✓ |  |  |
| unitisunit | input | dropdown |  |  |  |  |  |
| name | input | reference |  |  |  |  |  |
| realm | input | reference |  |  |  |  |  |
| namerealm | input | reference |  |  |  |  |  |
| class | input | dropdown |  |  |  |  |  |
| specId | input | dropdown |  |  |  | ✓ |  |
| classification | input | dropdown | {'elite': 'Elite', 'minus': 'Minus (Small Nameplate)', 'normal': 'Normal', 'rare': 'Rare', 'rareelite': 'Rare Elite', 'trivial': 'Trivial (Low Level)', 'worldboss': 'World Boss'} |  |  |  |  |
| creatureTypeIndex | input | dropdown | ['Beast', 'Dragonkin', {}, {}, {}, 'Undead', 'Humanoid', 'Critter', 'Mechanical', 'Not specified', 'Totem', 'Non-combat Pet', 'Gas Cloud', 'Wild Pet', 'Aberration'] |  |  |  |  |
| creatureFamilyIndex | input | dropdown | {'1': 'Wolf', '11': 'Raptor', '12': 'Tallstrider', '15': 'Felhunter', '16': 'Voidwalker', '17': 'Succubus', '19': 'Doomguard', '2': 'Cat', '20': {}, '21': 'Turtle', '23': 'Imp', '24': 'Bat', '25': 'Hyena', '26': 'Bird of Prey', '27': 'Wind Serpent', '28': 'Remote Control', '29': 'Felguard', '3': 'Spider', '30': 'Dragonhawk', '302': 'Incubus', '31': {}, '32': 'Warp Stalker', '33': 'Sporebat', '34': 'Nether Ray', '35': 'Serpent', '37': 'Moth', '38': 'Chimaera', '39': 'Devilsaur', '4': 'Bear', '40': 'Ghoul', '41': {}, '42': 'Worm', '43': 'Rhino', '44': 'Wasp', '45': 'Core Hound', '46': 'Spirit Beast', '5': 'Boar', '6': 'Crocolisk', '7': 'Carrion Bird', '8': 'Crab', '9': 'Gorilla'} |  |  |  |  |
| role | input | dropdown | {'caster': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Ranged', 'healer': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t ', 'melee': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Melee', 'tank': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t '} |  |  |  |  |
| raid_role | input | dropdown | {'MAINASSIST': '|TInterface\\GroupFrame\\UI-Group-mainassistIcon:16:16|t ', 'MAINTANK': '|TInterface\\GroupFrame\\UI-Group-maintankIcon:16:16|t ', 'NONE': 'Other'} |  |  | ✓ |  |
| raidMarkIndex | input | dropdown |  |  |  |  |  |
| dead | input | dropdown |  |  |  |  |  |
| ignoreSelf | input | toggle |  |  |  | ✓ |  |
| ignoreDisconnected | input | toggle |  |  |  | ✓ |  |
| inRange | input | toggle |  |  |  | ✓ |  |
| hostility | input | dropdown | {'friendly': 'Friendly', 'hostile': 'Hostile'} |  |  |  |  |
| character | input | dropdown | {'npc': 'Non-player Character', 'player': 'Player Character'} |  |  |  |  |
| level | input | value |  |  |  |  |  |
| npcId | input | reference |  |  |  |  |  |
| attackable | input | dropdown |  |  |  |  |  |
| inCombat | input | dropdown |  |  |  |  |  |
| afk | input | dropdown |  |  |  |  |  |
| dnd | input | dropdown |  |  |  |  |  |
| creatureType | provides | state |  |  |  |  |  |
| creatureFamily | provides | state |  |  |  |  |  |
| raidMark | provides | state |  |  |  |  |  |
