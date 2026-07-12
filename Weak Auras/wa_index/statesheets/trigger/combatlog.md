# Trigger type: combatlog  (`combatlog`)

_1 events. input = you fill · provides = trigger outputs (conditions/subregions) · seed = forced on · gated = conditional._


## Combat Log  (`Combat Log`)
default state: `{"type": "combatlog", "event": "Combat Log"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| sourceHeader | input | ui |  |  |  |  |  |
| sourceUnit | input | dropdown |  |  |  | ✓ |  |
| sourceName | input | reference |  |  |  |  |  |
| sourceNpcId | input | reference |  |  |  | ✓ |  |
| sourceFlags | input | dropdown | {'InGroup': 'In Group', 'InParty': 'In Party', 'Mine': 'Mine', 'NotInGroup': 'Not in Smart Group'} |  |  |  |  |
| sourceFlags2 | input | dropdown | {'Friendly': 'Friendly', 'Hostile': 'Hostile', 'Neutral': 'Neutral'} |  |  |  |  |
| sourceFlags3 | input | dropdown | {'Guardian': 'Guardian', 'NPC': 'NPC', 'Object': 'Object', 'Pet': 'Pet', 'Player': 'Player'} |  |  |  |  |
| destHeader | input | ui |  |  |  | ✓ |  |
| destUnit | input | dropdown |  |  |  | ✓ |  |
| destName | input | reference |  |  |  | ✓ |  |
| destNpcId | input | reference |  |  |  | ✓ |  |
| destFlags | input | dropdown | {'InGroup': 'In Group', 'InParty': 'In Party', 'Mine': 'Mine', 'NotInGroup': 'Not in Smart Group'} |  |  | ✓ |  |
| destFlags2 | input | dropdown | {'Friendly': 'Friendly', 'Hostile': 'Hostile', 'Neutral': 'Neutral'} |  |  | ✓ |  |
| destFlags3 | input | dropdown | {'Guardian': 'Guardian', 'NPC': 'NPC', 'Object': 'Object', 'Pet': 'Pet', 'Player': 'Player'} |  |  | ✓ |  |
| subeventHeader | input | ui |  |  |  | ✓ |  |
| spellId | input | reference |  |  |  | ✓ |  |
| spellName | input | reference |  |  |  | ✓ |  |
| spellSchool | input | dropdown | {'1': '001 - ', '10': '010 - ', '106': '106 - ', '12': '012 - ', '124': '124 - ', '126': '126 - ', '127': '127 - ', '16': '016 - ', '17': '017 - ', '18': '018 - ', '2': '002 - ', '20': '020 - ', '24': '024 - ', '28': '028 - ', '3': '003 - ', '32': '032 - ', '33': '033 - ', '34': '034 - ', '36': '036 - ', '4': '004 - ', '40': '040 - ', '48': '048 - ', '5': '005 - ', '6': '006 - ', '62': '062 - ', '64': '064 - ', '65': '065 - ', '66': '066 - ', '68': '068 - ', '72': '072 - ', '8': '008 - ', '80': '080 - ', '9': '009 - ', '96': '096 - '} |  |  | ✓ |  |
| environmentalType | input | dropdown | {'Drowning': {}, 'Falling': {}, 'Fatigue': {}, 'Fire': {}, 'Lava': {}, 'Slime': {}} |  |  | ✓ |  |
| missType | input | dropdown | {'ABSORB': 'Absorb', 'BLOCK': 'Block', 'DEFLECT': 'Deflect', 'DODGE': 'Dodge', 'EVADE': 'Evade', 'IMMUNE': 'Immune', 'MISS': 'Miss', 'PARRY': 'Parry', 'REFLECT': 'Reflect', 'RESIST': 'Resist'} |  |  | ✓ |  |
| extraSpellId | input | reference |  |  |  | ✓ |  |
| extraSpellName | input | reference |  |  |  | ✓ |  |
| auraType | input | dropdown | {'BUFF': 'Buff', 'DEBUFF': 'Debuff'} |  |  | ✓ |  |
| amount | input | value |  |  |  | ✓ |  |
| overkill | input | value |  |  |  | ✓ |  |
| overhealing | input | value |  |  |  | ✓ |  |
| resisted | input | value |  |  |  | ✓ |  |
| blocked | input | value |  |  |  | ✓ |  |
| absorbed | input | value |  |  |  | ✓ |  |
| critical | input | dropdown |  |  |  | ✓ |  |
| glancing | input | dropdown |  |  |  | ✓ |  |
| crushing | input | dropdown |  |  |  | ✓ |  |
| number | input | value |  |  |  | ✓ |  |
| overEnergize | input | value |  |  |  | ✓ |  |
| powerType | input | dropdown | {'0': {}, '1': {}, '2': {}, '27': {}, '3': {}, '6': {}} |  |  | ✓ |  |
| extraAmount | input | value |  |  |  | ✓ |  |
| miscellaneousHeader | input | ui |  |  |  |  |  |
| cloneId | input | toggle |  |  |  |  |  |
| sourceGUID | provides | state |  |  |  |  |  |
| destGUID | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
