# Trigger type: Spell  (`spell`)

_8 events. input = you fill · provides = trigger outputs (conditions/subregions) · seed = forced on · gated = conditional._


## Spell Usable  (`Action Usable`)
default state: `{"type": "spell", "event": "Action Usable", "use_spellName": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| spellName | input | reference |  |  | ✓ |  | →False |
| targetRequired | input | toggle |  |  |  |  |  |
| ignoreSpellCooldown | input | toggle |  |  |  |  |  |
| charges | input | value |  |  |  | ✓ |  |
| spellCount | input | value |  |  |  | ✓ |  |
| inverse | input | toggle |  |  |  |  |  |
| readyTime | provides | state |  |  |  | ✓ |  |
| chargeGainTime | provides | state |  |  |  | ✓ |  |
| chargeLostTime | provides | state |  |  |  | ✓ |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| stacks | provides | state |  |  |  | ✓ |  |
| spellInRange | internal | state |  |  |  |  |  |

## Charges Changed Event  (`Charges Changed`)
default state: `{"type": "spell", "event": "Charges Changed", "use_spellName": true, "use_direction": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| spellName | input | reference |  |  | ✓ |  | →False |
| direction | input | dropdown | {'CHANGED': 'Changed', 'GAINED': 'Gained', 'LOST': 'Lost'} |  | ✓ |  |  |
| charges | input | value |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Cooldown/Charges/Count  (`Cooldown Progress (Spell)`)
default state: `{"type": "spell", "event": "Cooldown Progress (Spell)", "use_spellName": true, "use_track": true, "track": "auto", "use_genericShowOn": true, "genericShowOn": "showOnCooldown"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| spellName | input | reference |  |  | ✓ |  | →False |
| extra Cooldown Progress (Spell) | input | ui |  |  |  |  |  |
| track | input | dropdown | {'auto': 'Auto', 'charges': 'Charges', 'cooldown': 'Cooldown'} | auto | ✓ |  |  |
| showgcd | input | toggle |  |  |  |  |  |
| matchedRune | input | toggle |  |  |  |  |  |
| ignoreSpellKnown | input | toggle |  |  |  |  |  |
| trackcharge | input | value |  |  |  | ✓ |  |
| remaining | input | value |  |  |  | ✓ |  |
| charges | input | value |  |  |  |  |  |
| spellCount | input | value |  |  |  |  |  |
| genericShowOn | input | dropdown | {'showAlways': 'Always', 'showOnCooldown': 'On Cooldown', 'showOnReady': 'Not on Cooldown'} | showOnCooldown | ✓ |  |  |
| stacks | provides | state |  |  |  |  |  |
| maxCharges | provides | state |  |  |  |  |  |
| readyTime | provides | state |  |  |  |  |  |
| chargeGainTime | provides | state |  |  |  |  |  |
| chargeLostTime | provides | state |  |  |  |  |  |
| effectiveSpellId | provides | state |  |  |  |  |  |
| gcdCooldown | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| onCooldown | internal | state |  |  |  |  |  |
| spellUsable | internal | state |  |  |  |  |  |
| insufficientResources | internal | state |  |  |  |  |  |
| spellInRange | internal | state |  |  |  |  |  |

## Cooldown Ready Event  (`Cooldown Ready (Spell)`)
default state: `{"type": "spell", "event": "Cooldown Ready (Spell)", "use_spellName": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| spellName | input | reference |  |  | ✓ |  | →False |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Global Cooldown  (`Global Cooldown`)
default state: `{"type": "spell", "event": "Global Cooldown"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| inverse | input | toggle |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| duration | provides | state |  |  |  |  |  |
| expirationTime | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |

## Queued Action  (`Queued Action`)
default state: `{"type": "spell", "event": "Queued Action", "use_spellName": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| spellName | input | reference |  |  | ✓ |  | →False |

## Spell Known  (`Spell Known`)
default state: `{"type": "spell", "event": "Spell Known", "use_spellName": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| spellName | input | reference |  |  | ✓ |  |  |
| petspell | input | toggle |  |  |  |  |  |
| inverse | input | toggle |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Totem  (`Totem`)
default state: `{"type": "spell", "event": "Totem"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| totemType | input | dropdown | ['Fire', 'Earth', 'Water', 'Air'] |  |  |  |  |
| totemName | input | reference |  |  |  |  |  |
| totemNamePattern | input | reference |  |  |  |  |  |
| icon | input | value |  |  |  |  |  |
| inverse | input | toggle |  |  |  |  |  |
| clones | input | toggle |  |  |  | ✓ |  |
| remaining | input | value |  |  |  | ✓ |  |
