# Trigger type: event  (`event`)

_5 events. input = you fill · provides = trigger outputs (conditions/subregions) · seed = forced on · gated = conditional._


## Chat Message  (`Chat Message`)
default state: `{"type": "event", "event": "Chat Message"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| messageType | input | dropdown | {'CHAT_MSG_BATTLEGROUND': 'Battleground', 'CHAT_MSG_BG_SYSTEM_ALLIANCE': 'BG-System Alliance', 'CHAT_MSG_BG_SYSTEM_HORDE': 'BG-System Horde', 'CHAT_MSG_BG_SYSTEM_NEUTRAL': 'BG-System Neutral', 'CHAT_MSG_BN_WHISPER': 'Battle.net Whisper', 'CHAT_MSG_CHANNEL': 'Channel', 'CHAT_MSG_EMOTE': 'Emote', 'CHAT_MSG_GUILD': 'Guild', 'CHAT_MSG_LOOT': 'Loot', 'CHAT_MSG_MONSTER_EMOTE': 'Monster Emote', 'CHAT_MSG_MONSTER_PARTY': 'Monster Party', 'CHAT_MSG_MONSTER_SAY': 'Monster Say', 'CHAT_MSG_MONSTER_WHISPER': 'Monster Whisper', 'CHAT_MSG_MONSTER_YELL': 'Monster Yell', 'CHAT_MSG_OFFICER': 'Officer', 'CHAT_MSG_PARTY': 'Party', 'CHAT_MSG_RAID': 'Raid', 'CHAT_MSG_RAID_BOSS_EMOTE': 'Boss Emote', 'CHAT_MSG_RAID_BOSS_WHISPER': 'Boss Whisper', 'CHAT_MSG_RAID_WARNING': 'Raid Warning', 'CHAT_MSG_SAY': 'Say', 'CHAT_MSG_SYSTEM': 'System', 'CHAT_MSG_WHISPER': 'Whisper', 'CHAT_MSG_YELL': 'Yell'} |  |  |  |  |
| message | input | reference |  |  |  |  |  |
| sourceName | input | reference |  |  |  |  |  |
| destName | input | reference |  |  |  |  |  |
| cloneId | input | toggle |  |  |  |  |  |
| sourceGUID | provides | state |  |  |  |  |  |

## Entering/Leaving Combat  (`Combat Events`)
default state: `{"type": "event", "event": "Combat Events", "use_eventtype": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| eventtype | input | dropdown | {'PLAYER_REGEN_DISABLED': 'Entering', 'PLAYER_REGEN_ENABLED': 'Leaving'} |  | ✓ |  |  |

## Entering/Leaving Encounter  (`Encounter Events`)
default state: `{"type": "event", "event": "Encounter Events", "use_eventtype": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| note | input | ui |  |  |  |  |  |
| eventtype | input | dropdown | {'ENCOUNTER_END': 'Leaving', 'ENCOUNTER_START': 'Entering'} |  | ✓ |  |  |
| encounterId | input | reference |  |  |  |  |  |
| encounterName | input | reference |  |  |  |  |  |
| difficulty | input | dropdown | {'ascended': 'Ascended', 'heroic': {}, 'mythic': 'Mythic', 'none': 'None', 'normal': {}} |  |  |  |  |
| success | input | toggle |  |  |  | ✓ |  |

## Ready Check  (`Ready Check`)
default state: `{"type": "event", "event": "Ready Check"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|

## Spell Cast Succeeded  (`Spell Cast Succeeded`)
default state: `{"type": "event", "event": "Spell Cast Succeeded"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| unit | input | dropdown |  |  |  |  |  |
| spellNames | input | reference |  |  |  |  |  |
| spellId | input | reference |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
