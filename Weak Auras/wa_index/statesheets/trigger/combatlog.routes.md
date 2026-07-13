# combatlog - routing index
_Main (input) levers only. Open `combatlog.json` for full handling. rule: `array`=multiEntry (value+operator as arrays) - `dom:X`=value-domain X (see domains.json)._

## Combat Log  - progress: timed
| lever | type | rule |
|---|---|---|
| sourceHeader (Source Info) | header |  |
| sourceUnit (Source Unit) | unit |  |
| sourceName (Source Name) | string |  |
| sourceNpcId (Source NPC Id) | string |  |
| sourceFlags (Source Affiliation) | select | dom:{'InGroup': 'In Group', 'InParty': 'In Party', 'Mine': 'Mine', 'NotInGroup': 'Not in Smart Group'} |
| sourceFlags2 (Source Reaction) | select | dom:{'Friendly': 'Friendly', 'Hostile': 'Hostile', 'Neutral': 'Neutral'} |
| sourceFlags3 (Source Object Type) | select | dom:{'Guardian': 'Guardian', 'NPC': 'NPC', 'Object': 'Object', 'Pet': 'Pet', 'Player': 'Player'} |
| destHeader (Destination Info) | header |  |
| destUnit (Destination Unit) | unit |  |
| destName (Destination Name) | string |  |
| destNpcId (Destination NPC Id) | string |  |
| destFlags (Destination Affiliation) | select | dom:{'InGroup': 'In Group', 'InParty': 'In Party', 'Mine': 'Mine', 'NotInGroup': 'Not in Smart Group'} |
| destFlags2 (Destination Reaction) | select | dom:{'Friendly': 'Friendly', 'Hostile': 'Hostile', 'Neutral': 'Neutral'} |
| destFlags3 (Destination Object Type) | select | dom:{'Guardian': 'Guardian', 'NPC': 'NPC', 'Object': 'Object', 'Pet': 'Pet', 'Player': 'Player'} |
| subeventHeader (Subevent Info) | header |  |
| spellId (Spell Id) | spell | array |
| spellName (Spell Name) | spell | array |
| spellSchool (Spell School) | select | dom:{'1': '001 - ', '10': '010 - ', '106': '106 - ', '12': '012 - ', '124': '124 - ', '126': '126 - ', '127': '127 - ', '16': '016 - ', '17': '017 - ', '18': '018 - ', '2': '002 - ', '20': '020 - ', '24': '024 - ', '28': '028 - ', '3': '003 - ', '32': '032 - ', '33': '033 - ', '34': '034 - ', '36': '036 - ', '4': '004 - ', '40': '040 - ', '48': '048 - ', '5': '005 - ', '6': '006 - ', '62': '062 - ', '64': '064 - ', '65': '065 - ', '66': '066 - ', '68': '068 - ', '72': '072 - ', '8': '008 - ', '80': '080 - ', '9': '009 - ', '96': '096 - '} |
| environmentalType (Environment Type) | select | dom:{'Drowning': {}, 'Falling': {}, 'Fatigue': {}, 'Fire': {}, 'Lava': {}, 'Slime': {}} |
| missType (Miss Type) | select | dom:{'ABSORB': 'Absorb', 'BLOCK': 'Block', 'DEFLECT': 'Deflect', 'DODGE': 'Dodge', 'EVADE': 'Evade', 'IMMUNE': 'Immune', 'MISS': 'Miss', 'PARRY': 'Parry', 'REFLECT': 'Reflect', 'RESIST': 'Resist'} |
| extraSpellId (Extra Spell Id) | spell |  |
| extraSpellName (Extra Spell Name) | spell |  |
| auraType (Aura Type) | select | dom:{'BUFF': 'Buff', 'DEBUFF': 'Debuff'} |
| amount (Amount) | number |  |
| overkill (Overkill) | number |  |
| overhealing (Overhealing) | number |  |
| resisted (Resisted) | number |  |
| blocked (Blocked) | number |  |
| absorbed (Absorbed) | number |  |
| critical (Critical) | tristate |  |
| glancing (Glancing) | tristate |  |
| crushing (Crushing) | tristate |  |
| number (Number) | number |  |
| overEnergize (Over Energize) | number |  |
| powerType (Power Type) | select | dom:{'0': {}, '1': {}, '2': {}, '27': {}, '3': {}, '6': {}} |
| extraAmount (Extra Amount) | number |  |
| miscellaneousHeader (Miscellaneous) | header |  |
| cloneId (Clone per Event) | toggle |  |
