# event - routing index
_Main (input) levers only. Open `event.json` for full handling. rule: `array`=multiEntry (value+operator as arrays) - `dom:X`=value-domain X (see domains.json)._

## Chat Message  - progress: timed
| lever | type | rule |
|---|---|---|
| messageType (Message Type) | select | dom:{'CHAT_MSG_BATTLEGROUND': 'Battleground', 'CHAT_MSG_BG_SYSTEM_ALLIANCE': 'BG-System Alliance', 'CHAT_MSG_BG_SYSTEM_HORDE': 'BG-System Horde', 'CHAT_MSG_BG_SYSTEM_NEUTRAL': 'BG-System Neutral', 'CHAT_MSG_BN_WHISPER': 'Battle.net Whisper', 'CHAT_MSG_CHANNEL': 'Channel', 'CHAT_MSG_EMOTE': 'Emote', 'CHAT_MSG_GUILD': 'Guild', 'CHAT_MSG_LOOT': 'Loot', 'CHAT_MSG_MONSTER_EMOTE': 'Monster Emote', 'CHAT_MSG_MONSTER_PARTY': 'Monster Party', 'CHAT_MSG_MONSTER_SAY': 'Monster Say', 'CHAT_MSG_MONSTER_WHISPER': 'Monster Whisper', 'CHAT_MSG_MONSTER_YELL': 'Monster Yell', 'CHAT_MSG_OFFICER': 'Officer', 'CHAT_MSG_PARTY': 'Party', 'CHAT_MSG_RAID': 'Raid', 'CHAT_MSG_RAID_BOSS_EMOTE': 'Boss Emote', 'CHAT_MSG_RAID_BOSS_WHISPER': 'Boss Whisper', 'CHAT_MSG_RAID_WARNING': 'Raid Warning', 'CHAT_MSG_SAY': 'Say', 'CHAT_MSG_SYSTEM': 'System', 'CHAT_MSG_WHISPER': 'Whisper', 'CHAT_MSG_YELL': 'Yell'} |
| message (Message) | longstring |  |
| sourceName (Source Name) | string |  |
| destName (Destination Name) | string |  |
| cloneId (Clone per Event) | toggle |  |

## Combat Events  - progress: timed
| lever | type | rule |
|---|---|---|
| eventtype (Type) | select | dom:{'PLAYER_REGEN_DISABLED': 'Entering', 'PLAYER_REGEN_ENABLED': 'Leaving'} |

## Encounter Events  - progress: timed
| lever | type | rule |
|---|---|---|
| note | description |  |
| eventtype (Type) | select | dom:{'ENCOUNTER_END': 'Leaving', 'ENCOUNTER_START': 'Entering'} |
| encounterId (Id) | string |  |
| encounterName (Name) | string |  |
| difficulty (Difficulty) | select | dom:{'ascended': 'Ascended', 'heroic': {}, 'mythic': 'Mythic', 'none': 'None', 'normal': {}} |
| success (Success) | toggle |  |

## Ready Check  - progress: timed
_(no input levers)_

## Spell Cast Succeeded  - progress: timed
| lever | type | rule |
|---|---|---|
| unit (Caster Unit) | unit |  |
| spellNames (Name(s)) | spell | array |
| spellId (Exact Spell ID(s)) | spell | array |
