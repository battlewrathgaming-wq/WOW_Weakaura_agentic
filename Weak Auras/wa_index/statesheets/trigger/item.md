# Trigger type: Item  (`item`)

_9 events. input = you fill · provides = trigger outputs (conditions/subregions) · seed = forced on · gated = conditional._


## Cooldown Progress (Slot)  (`Cooldown Progress (Equipment Slot)`)
default state: `{"type": "item", "event": "Cooldown Progress (Equipment Slot)", "use_itemSlot": true, "use_genericShowOn": true, "genericShowOn": "showOnCooldown"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| itemSlot | input | dropdown | {'0': {}, '1': {}, '10': {}, '11': {}, '12': {}, '13': {}, '14': {}, '15': {}, '16': {}, '17': {}, '18': {}, '19': {}, '2': {}, '3': {}, '5': {}, '6': {}, '7': {}, '8': {}, '9': {}} |  | ✓ |  |  |
| extra Cooldown Progress (Equipment Slot) | input | ui |  |  |  |  |  |
| showgcd | input | toggle |  |  |  |  |  |
| remaining | input | value |  |  |  | ✓ |  |
| testForCooldown | input | toggle |  |  |  |  |  |
| genericShowOn | input | dropdown | {'showAlways': 'Always', 'showOnCooldown': 'On Cooldown', 'showOnReady': 'Not on Cooldown'} | showOnCooldown | ✓ |  |  |
| itemId | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| duration | provides | state |  |  |  |  |  |
| expirationTime | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| stacks | provides | state |  |  |  |  |  |
| gcdCooldown | provides | state |  |  |  |  |  |
| onCooldown | internal | state |  |  |  |  |  |

## Cooldown Progress (Item)  (`Cooldown Progress (Item)`)
default state: `{"type": "item", "event": "Cooldown Progress (Item)", "use_itemName": true, "use_genericShowOn": true, "genericShowOn": "showOnCooldown"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| itemName | input | reference |  |  | ✓ |  |  |
| remaining | input | value |  |  |  | ✓ |  |
| extra Cooldown Progress (Item) | input | ui |  |  |  |  |  |
| showgcd | input | toggle |  |  |  |  |  |
| genericShowOn | input | dropdown | {'showAlways': 'Always', 'showOnCooldown': 'On Cooldown', 'showOnReady': 'Not on Cooldown'} | showOnCooldown | ✓ |  |  |
| enabled | provides | state |  |  |  |  |  |
| gcdCooldown | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| duration | provides | state |  |  |  |  |  |
| expirationTime | provides | state |  |  |  |  |  |
| onCooldown | internal | state |  |  |  |  |  |

## Cooldown Ready Event (Slot)  (`Cooldown Ready (Equipment Slot)`)
default state: `{"type": "item", "event": "Cooldown Ready (Equipment Slot)", "use_itemSlot": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| itemSlot | input | dropdown | {'0': {}, '1': {}, '10': {}, '11': {}, '12': {}, '13': {}, '14': {}, '15': {}, '16': {}, '17': {}, '18': {}, '19': {}, '2': {}, '3': {}, '5': {}, '6': {}, '7': {}, '8': {}, '9': {}} |  | ✓ |  |  |
| itemId | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Cooldown Ready Event (Item)  (`Cooldown Ready (Item)`)
default state: `{"type": "item", "event": "Cooldown Ready (Item)", "use_itemName": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| itemName | input | reference |  |  | ✓ |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Equipment Set Equipped  (`Equipment Set`)
default state: `{"type": "item", "event": "Equipment Set"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| itemSetName | input | reference |  |  |  |  |  |
| partial | input | toggle |  |  |  |  |  |
| inverse | input | toggle |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| value | provides | state |  |  |  |  |  |
| total | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |

## Item Count  (`Item Count`)
default state: `{"type": "item", "event": "Item Count", "use_itemName": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| itemName | input | reference |  |  | ✓ |  | →False |
| name | input | state |  |  |  |  |  |
| includeBank | input | toggle |  |  |  |  |  |
| includeCharges | input | toggle |  |  |  |  |  |
| count | input | value |  |  |  |  |  |
| stacks | provides | state |  |  |  |  |  |
| value | provides | state |  |  |  |  |  |
| total | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |

## Item Equipped  (`Item Equipped`)
default state: `{"type": "item", "event": "Item Equipped", "use_itemName": true}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| itemName | input | reference |  |  | ✓ |  |  |
| itemSlot | input | dropdown | {'0': {}, '1': {}, '10': {}, '11': {}, '12': {}, '13': {}, '14': {}, '15': {}, '16': {}, '17': {}, '18': {}, '19': {}, '2': {}, '3': {}, '5': {}, '6': {}, '7': {}, '8': {}, '9': {}} |  |  |  |  |
| inverse | input | toggle |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |

## Item Type Equipped  (`Item Type Equipped`)
default state: `{"type": "item", "event": "Item Type Equipped"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| itemTypeName | input | dropdown |  |  | ✓ |  |  |

## Weapon Enchant / Fishing Lure  (`Weapon Enchant`)
default state: `{"type": "item", "event": "Weapon Enchant", "use_weapon": true, "weapon": "main", "use_showOn": true, "showOn": "showOnActive"}`

| option | surface | input | domain | default | seed | gated | policy |
|---|---|---|---|---|---|---|---|
| weapon | input | dropdown | {'main': {}, 'off': {}, 'ranged': {}} | main | ✓ |  |  |
| enchant | input | reference |  |  |  |  |  |
| stacks | input | value |  |  |  |  |  |
| remaining | input | value |  |  |  | ✓ |  |
| showOn | input | dropdown |  | showOnActive | ✓ |  |  |
| enchantID | provides | state |  |  |  |  |  |
| duration | provides | state |  |  |  |  |  |
| expirationTime | provides | state |  |  |  |  |  |
| progressType | provides | state |  |  |  |  |  |
| name | provides | state |  |  |  |  |  |
| icon | provides | state |  |  |  |  |  |
| enchanted | provides | state |  |  |  |  |  |
