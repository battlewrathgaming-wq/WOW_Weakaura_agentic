# unit - routing index
_Main (input) levers only. Open `unit.json` for full handling. rule: `array`=multiEntry (value+operator as arrays) - `dom:X`=value-domain X (see domains.json)._

## Cast  - progress: timed
| lever | type | rule |
|---|---|---|
| unit (Unit) | unit |  |
| spellNames (Name(s)) | spell | array |
| spellIds (Exact Spell ID(s)) | spell | array |
| spell (Spellname) | string |  |
| castType (Cast Type) | select | dom:{'cast': 'Cast', 'channel': 'Channel (Spell)'} |
| interruptible (Interruptible) | tristate |  |
| remaining (Remaining Time) | number |  |
| unitCharacteristicsHeader (Unit Characteristics) | header |  |
| npcId (Npc ID) | string |  |
| class (Class) | select |  |
| role (Spec Role) | select | dom:{'caster': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Ranged', 'healer': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t ', 'melee': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Melee', 'tank': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t '} |
| raid_role (Raid Role) | select | dom:{'MAINASSIST': '|TInterface\\GroupFrame\\UI-Group-mainassistIcon:16:16|t ', 'MAINTANK': '|TInterface\\GroupFrame\\UI-Group-maintankIcon:16:16|t ', 'NONE': 'Other'} |
| raidMarkIndex (Raid Mark) | multiselect |  |
| nameplateType (Hostility) | select | dom:{'friendly': 'Friendly', 'hostile': 'Hostile'} |
| sourceUnit (Caster) | unit |  |
| sourceName (Caster Name) | string |  |
| sourceRealm (Caster Realm) | string |  |
| sourceNameRealm (Source Unit Name/Realm) | string |  |
| destUnit (Caster's Target) | unit |  |
| destName (Name of Caster's Target) | string |  |
| destRealm (Realm of Caster's Target) | string |  |
| destNameRealm (Name/Realm of Caster's Target) | string |  |
| miscellaneousHeader (Miscellaneous) | header |  |
| showLatency (Overlay Latency) | toggle |  |
| includePets (Include Pets) | select | dom:{'PetsOnly': 'Pets only', 'PlayersAndPets': 'Players and Pets'} |
| ignoreSelf (Ignore Self) | toggle |  |
| onUpdateUnitTarget (Advanced Caster's Target Check) | toggle |  |
| inverse (Inverse) | toggle |  |

## Character Stats  - progress: none
| lever | type | rule |
|---|---|---|
| primaryStatsHeader (Primary Stats) | header |  |
| strength (Strength) | number | array |
| agility (Agility) | number | array |
| stamina (Stamina) | number | array |
| intellect (Intellect) | number | array |
| spirit (Spirit) | number | array |
| secondaryStatsHeader (Secondary Stats) | header |  |
| criticalrating (Critical Rating) | number | array |
| criticalpercent (Critical (%)) | number | array |
| hitrating (Hit Rating) | number | array |
| hitpercent (Hit (%)) | number | array |
| hasterating (Haste Rating) | number | array |
| hastepercent (Haste (%)) | number | array |
| expertiserating (Expertise Rating) | number | array |
| expertisebonus (Expertise Bonus) | number | array |
| armorpenrating (Armor Peneration Rating) | number | array |
| armorpenpercent (Armor Peneration (%)) | number | array |
| spellpenpercent (Spell Peneration (%)) | number | array |
| resiliencerating (Resilience Rating) | number | array |
| resiliencepercent (Resilience (%)) | number | array |
| attackpower (Attack Power) | number | array |
| spellpower (Spell Power) | number | array |
| rangedattackpower (Ranged Attack Power) | number | array |
| resistanceHeader (Resistances) | header |  |
| resistancefire (Fire Resistance) | number | array |
| resistancenature (Nature Resistance) | number | array |
| resistancefrost (Frost Resistance) | number | array |
| resistanceshadow (Shadow Resistance) | number | array |
| resistancearcane (Arcane Resistance) | number | array |
| tertiaryStatsHeader (Tertiary Stats) | header |  |
| moveSpeed (Continuously update Movement Speed) | boolean |  |
| movespeedpercent (Current Movement Speed (%)) | number | array |
| defensiveStatsHeader (Defensive Stats) | header |  |
| defense (Defense) | number | array |
| defensevalue (Defense Value) | number |  |
| defensepercent (Defense (%)) | number |  |
| dodgerating (Dodge Rating) | number | array |
| dodgepercent (Dodge (%)) | number | array |
| parryrating (Parry Rating) | number | array |
| parrypercent (Parry (%)) | number | array |
| blockpercent (Block (%)) | number | array |
| blockvalue (Block Value) | number | array |
| armorrating (Armor Rating) | number | array |
| armorpercent (Armor (%)) | number | array |
| avoidancetotalpercent (Total Avoidance (%)) | number |  |

## Class/Spec  - progress: none
| lever | type | rule |
|---|---|---|
| specId (Class and Specialization) | multiselect |  |

## Conditions  - progress: none
| lever | type | rule |
|---|---|---|
| alwaystrue (Always active trigger) | tristate |  |
| incombat (In Combat) | tristate |  |
| pvpflagged (PvP Flagged) | tristate |  |
| alive (Alive) | tristate |  |
| vehicle (In Vehicle) | tristate |  |
| resting (Resting) | tristate |  |
| mounted (Mounted) | tristate |  |
| HasPet | tristate |  |
| ismoving (Is Moving) | tristate |  |
| afk (Is Away from Keyboard) | tristate |  |
| ingroup (Group Type) | multiselect | dom:{'group': 'In Party', 'raid': 'In Raid', 'solo': 'Not in Group'} |
| ruleset (PvP Ruleset) | multiselect | dom:{'highrisk': {}, 'one': 'None', 'pve': {}, 'pvp': {}} |
| instance_size (Instance Type) | multiselect | dom:{'arena': 'Arena', 'fortyman': '40 Man Raid', 'none': 'No Instance', 'party': '5 Man Dungeon', 'pvp': 'Battleground', 'ten': '10 Man Raid', 'twenty': '20 Man Raid', 'twentyfive': '25 Man Raid'} |
| instance_difficulty (Instance Difficulty) | multiselect | dom:{'ascended': 'Ascended', 'heroic': {}, 'mythic': 'Mythic', 'none': 'None', 'normal': {}} |

## Crowd Controlled
| lever | type | rule |
|---|---|---|
| controlled (Crowd Controlled) | tristate |  |

## Currency  - progress: static
| lever | type | rule |
|---|---|---|
| currencyId (Currency) | currency |  |
| value (Quantity) | number |  |
| totalEarned (Total) | number |  |
| description (Description) | string |  |
| discovered (Discovered) | tristate |  |

## Death Knight Rune  - progress: <function>
| lever | type | rule |
|---|---|---|
| rune (Rune) | select | dom:['Blood Rune #1', 'Blood Rune #2', 'Unholy Rune #1', 'Unholy Rune #2', 'Frost Rune #1', 'Frost Rune #2'] |
| isDeathRune (Is Death Rune) | tristate |  |
| remaining (Remaining Time) | number |  |
| genericShowOn (Show) | select | dom:{'showAlways': 'Always', 'showOnCooldown': 'On Cooldown', 'showOnReady': 'Not on Cooldown'} |
| runesCount (Rune Count) | number |  |
| bloodRunes (Rune Count - Blood) | number |  |
| frostRunes (Rune Count - Frost) | number |  |
| unholyRunes (Rune Count - Unholy) | number |  |
| includeDeathRunes (Include Death Runes) | toggle |  |

## Experience  - progress: static
| lever | type | rule |
|---|---|---|
| level (Level) | number | array |
| currentXP (Current Experience) | number | array |
| totalXP (Total Experience) | number | array |
| value | number |  |
| total | number |  |
| percentXP (Experience (%)) | number | array |
| restedExperienceHeader (Rested Experience) | header |  |
| showRested (Show Rested Overlay) | toggle |  |
| restedXP (Rested Experience) | number | array |
| percentrested (Rested Experience (%)) | number | array |

## Faction Reputation  - progress: static
| lever | type | rule |
|---|---|---|
| watched (Use Watched Faction) | toggle |  |
| factionID (Faction) | select |  |
| name (Faction Name) | string |  |
| value (Reputation) | number | array |
| total (Total Reputation) | number | array |
| percentRep (Reputation (%)) | number | array |
| standing (Standing) | string |  |
| standingId (Standing) | select |  |
| capped (Capped) | tristate |  |
| atWar (At War) | tristate |  |

## Health  - progress: static
| lever | type | rule |
|---|---|---|
| unit (Unit) | unit |  |
| health (Health) | number | array |
| percenthealth (Health (%)) | number | array |
| deficit (Health Deficit) | number | array |
| maxhealth (Max Health) | number | array |
| showAbsorb (Show Absorb) | toggle |  |
| absorbMode (Absorb Display) | select | dom:{'OVERLAY_FROM_END': 'Attach to End', 'OVERLAY_FROM_START': 'Attach to Start'} |
| absorb (Absorb) | number |  |
| unitCharacteristicsHeader (Unit Characteristics) | header |  |
| name | string |  |
| realm (Realm) | string |  |
| namerealm (Unit Name/Realm) | string |  |
| npcId (Npc ID) | string |  |
| class (Class) | select |  |
| specId (Specialization) | multiselect |  |
| role (Spec Role) | select | dom:{'caster': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Ranged', 'healer': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t ', 'melee': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Melee', 'tank': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t '} |
| raid_role (Raid Role) | select | dom:{'MAINASSIST': '|TInterface\\GroupFrame\\UI-Group-mainassistIcon:16:16|t ', 'MAINTANK': '|TInterface\\GroupFrame\\UI-Group-maintankIcon:16:16|t ', 'NONE': 'Other'} |
| raidMarkIndex (Raid Mark) | multiselect |  |
| miscellaneousHeader (Miscellaneous) | header |  |
| includePets (Include Pets) | select | dom:{'PetsOnly': 'Pets only', 'PlayersAndPets': 'Players and Pets'} |
| ignoreSelf (Ignore Self) | toggle |  |
| ignoreDead (Ignore Dead) | toggle |  |
| ignoreDisconnected (Ignore Disconnected) | toggle |  |
| inRange (In Range) | toggle |  |
| nameplateType (Hostility) | select | dom:{'friendly': 'Friendly', 'hostile': 'Hostile'} |

## Location  - progress: none
| lever | type | rule |
|---|---|---|
| zoneIds (Player Location ID(s)) | string |  |
| zone (Zone Name) | string | array |
| subzone (Subzone Name) | string | array |
| instanceHeader (Instance Info) | header |  |
| instanceSize (Instance Size Type) | multiselect | dom:{'arena': 'Arena', 'fortyman': '40 Man Raid', 'none': 'No Instance', 'party': '5 Man Dungeon', 'pvp': 'Battleground', 'ten': '10 Man Raid', 'twenty': '20 Man Raid', 'twentyfive': '25 Man Raid'} |
| instanceDifficulty (Instance Difficulty) | multiselect | dom:{'ascended': 'Ascended', 'heroic': {}, 'mythic': 'Mythic', 'none': 'None', 'normal': {}} |

## Money  - progress: none
| lever | type | rule |
|---|---|---|
| money (Money) | number |  |
| gold (Gold) | number |  |
| silver (Silver) | number |  |
| copper (Copper) | number |  |

## Pet Behavior  - progress: none
| lever | type | rule |
|---|---|---|
| behavior (Pet Behavior) | select | dom:{'aggressive': {}, 'defensive': {}, 'passive': {}} |
| inverse (Inverse Pet Behavior) | toggle |  |

## Power  - progress: static
| lever | type | rule |
|---|---|---|
| unit (Unit) | unit |  |
| powertype (Power Type) | select |  |
| requirePowerType (Only if Primary) | toggle |  |
| showCost (Overlay Cost of Casts) | toggle |  |
| power (Power) | number | array |
| percentpower (Power (%)) | number | array |
| deficit (Power Deficit) | number | array |
| maxpower (Max Power) | number | array |
| name (Unit Name) | string |  |
| realm (Realm) | string |  |
| unitCharacteristicsHeader (Unit Characteristics) | header |  |
| namerealm (Unit Name/Realm) | string |  |
| npcId (Npc ID) | string |  |
| class (Class) | select |  |
| specId (Specialization) | multiselect |  |
| role (Spec Role) | select | dom:{'caster': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Ranged', 'healer': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t ', 'melee': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Melee', 'tank': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t '} |
| raid_role (Raid Role) | select | dom:{'MAINASSIST': '|TInterface\\GroupFrame\\UI-Group-mainassistIcon:16:16|t ', 'MAINTANK': '|TInterface\\GroupFrame\\UI-Group-maintankIcon:16:16|t ', 'NONE': 'Other'} |
| raidMarkIndex (Raid Mark) | multiselect |  |
| miscellaneousHeader (Miscellaneous) | header |  |
| includePets (Include Pets) | select | dom:{'PetsOnly': 'Pets only', 'PlayersAndPets': 'Players and Pets'} |
| ignoreSelf (Ignore Self) | toggle |  |
| ignoreDead (Ignore Dead) | toggle |  |
| ignoreDisconnected (Ignore Disconnected) | toggle |  |
| inRange (In Range) | toggle |  |
| nameplateType (Hostility) | select | dom:{'friendly': 'Friendly', 'hostile': 'Hostile'} |

## Range Check  - progress: none
| lever | type | rule |
|---|---|---|
| note | description |  |
| unit (Unit) | unit |  |
| minRange (Minimum Estimate) | number |  |
| maxRange (Maximum Estimate) | number |  |
| range (Distance) | number |  |

## Stance/Form/Aura  - progress: none
| lever | type | rule |
|---|---|---|
| note | description |  |
| form (Form) | multiselect |  |
| inverse (Inverse) | toggle |  |

## Swing Timer  - progress: timed
| lever | type | rule |
|---|---|---|
| note | description |  |
| hand (Weapon) | select | dom:{'main': {}, 'off': {}, 'ranged': {}} |
| remaining (Remaining Time) | number |  |
| inverse (Inverse) | toggle |  |

## Talent Known  - progress: none
| lever | type | rule |
|---|---|---|
| spellName (Talent) | talent |  |
| inverse (Inverse) | toggle |  |

## Threat Situation  - progress: static
| lever | type | rule |
|---|---|---|
| unit (Unit) | unit |  |
| status (Status) | select | dom:{'-1': 'Not On Threat Table', '0': '|cFFB0B0B0Lower Than Tank|r', '1': '|cFFFFFF77Higher Than Tank|r', '2': '|cFFFF9900Tanking But Not Highest|r', '3': '|cFFFF0000Tanking And Highest|r'} |
| aggro (Aggro) | tristate |  |
| threatpct (Threat Percent) | number | array |
| rawthreatpct (Raw Threat Percent) | number | array |
| threatvalue (Threat Value) | number | array |
| unitCharacteristicsHeader (Unit Characteristics) | header |  |
| name (Unit Name) | string |  |
| npcId (Npc ID) | string |  |

## Unit Characteristics  - progress: none
| lever | type | rule |
|---|---|---|
| unit (Unit) | unit |  |
| unitisunit (Unit is Unit) | unit |  |
| name (Name) | string |  |
| realm (Realm) | string |  |
| namerealm (Unit Name/Realm) | string |  |
| class (Class) | select |  |
| specId (Specialization) | multiselect |  |
| classification (Classification) | multiselect | dom:{'elite': 'Elite', 'minus': 'Minus (Small Nameplate)', 'normal': 'Normal', 'rare': 'Rare', 'rareelite': 'Rare Elite', 'trivial': 'Trivial (Low Level)', 'worldboss': 'World Boss'} |
| creatureTypeIndex (Creature Type) | multiselect | dom:['Beast', 'Dragonkin', {}, {}, {}, 'Undead', 'Humanoid', 'Critter', 'Mechanical', 'Not specified', 'Totem', 'Non-combat Pet', 'Gas Cloud', 'Wild Pet', 'Aberration'] |
| creatureFamilyIndex (Creature Family) | multiselect | dom:{'1': 'Wolf', '11': 'Raptor', '12': 'Tallstrider', '15': 'Felhunter', '16': 'Voidwalker', '17': 'Succubus', '19': 'Doomguard', '2': 'Cat', '20': {}, '21': 'Turtle', '23': 'Imp', '24': 'Bat', '25': 'Hyena', '26': 'Bird of Prey', '27': 'Wind Serpent', '28': 'Remote Control', '29': 'Felguard', '3': 'Spider', '30': 'Dragonhawk', '302': 'Incubus', '31': {}, '32': 'Warp Stalker', '33': 'Sporebat', '34': 'Nether Ray', '35': 'Serpent', '37': 'Moth', '38': 'Chimaera', '39': 'Devilsaur', '4': 'Bear', '40': 'Ghoul', '41': {}, '42': 'Worm', '43': 'Rhino', '44': 'Wasp', '45': 'Core Hound', '46': 'Spirit Beast', '5': 'Boar', '6': 'Crocolisk', '7': 'Carrion Bird', '8': 'Crab', '9': 'Gorilla'} |
| role (Spec Role) | select | dom:{'caster': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Ranged', 'healer': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t ', 'melee': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t Melee', 'tank': '|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t '} |
| raid_role (Raid Role) | select | dom:{'MAINASSIST': '|TInterface\\GroupFrame\\UI-Group-mainassistIcon:16:16|t ', 'MAINTANK': '|TInterface\\GroupFrame\\UI-Group-maintankIcon:16:16|t ', 'NONE': 'Other'} |
| raidMarkIndex (Raid Mark) | multiselect |  |
| dead (Dead) | tristate |  |
| ignoreSelf (Ignore Self) | toggle |  |
| ignoreDisconnected (Ignore Disconnected) | toggle |  |
| inRange (In Range) | toggle |  |
| hostility (Hostility) | select | dom:{'friendly': 'Friendly', 'hostile': 'Hostile'} |
| character (Character Type) | select | dom:{'npc': 'Non-player Character', 'player': 'Player Character'} |
| level (Level) | number | array |
| npcId (Npc ID) | string |  |
| attackable (Attackable) | tristate |  |
| inCombat (In Combat) | tristate |  |
| afk (Afk) | tristate |  |
| dnd (Do Not Disturb) | tristate |  |
