# item - routing index
_Main (input) levers only. Open `item.json` for full handling. rule: `array`=multiEntry (value+operator as arrays) - `dom:X`=value-domain X (see domains.json)._

## Cooldown Progress (Equipment Slot)  - progress: timed
| lever | type | rule |
|---|---|---|
| itemSlot (Equipment Slot) | select | dom:{'0': {}, '1': {}, '10': {}, '11': {}, '12': {}, '13': {}, '14': {}, '15': {}, '16': {}, '17': {}, '18': {}, '19': {}, '2': {}, '3': {}, '5': {}, '6': {}, '7': {}, '8': {}, '9': {}} |
| extra Cooldown Progress (Equipment Slot) (<function>) | collapse |  |
| showgcd (Show Global Cooldown) | toggle |  |
| remaining (Remaining Time) | number |  |
| testForCooldown (is useable) | toggle |  |
| genericShowOn (Show) | select | dom:{'showAlways': 'Always', 'showOnCooldown': 'On Cooldown', 'showOnReady': 'Not on Cooldown'} |

## Cooldown Progress (Item)  - progress: timed
| lever | type | rule |
|---|---|---|
| itemName (Item) | item |  |
| remaining (Remaining Time) | number |  |
| extra Cooldown Progress (Item) (<function>) | collapse |  |
| showgcd (Show Global Cooldown) | toggle |  |
| genericShowOn (Show) | select | dom:{'showAlways': 'Always', 'showOnCooldown': 'On Cooldown', 'showOnReady': 'Not on Cooldown'} |

## Cooldown Ready (Equipment Slot)  - progress: timed
| lever | type | rule |
|---|---|---|
| itemSlot (Equipment Slot) | select | dom:{'0': {}, '1': {}, '10': {}, '11': {}, '12': {}, '13': {}, '14': {}, '15': {}, '16': {}, '17': {}, '18': {}, '19': {}, '2': {}, '3': {}, '5': {}, '6': {}, '7': {}, '8': {}, '9': {}} |

## Cooldown Ready (Item)  - progress: timed
| lever | type | rule |
|---|---|---|
| itemName (Item) | item |  |

## Equipment Set  - progress: static
| lever | type | rule |
|---|---|---|
| itemSetName (Equipment Set) | string |  |
| partial (Allow partial matches) | toggle |  |
| inverse (Inverse) | toggle |  |

## Item Count  - progress: static
| lever | type | rule |
|---|---|---|
| itemName (Item) | item |  |
| name | string |  |
| includeBank (Include Bank) | toggle |  |
| includeCharges (Include Charges) | toggle |  |
| count (Item Count) | number |  |

## Item Equipped  - progress: none
| lever | type | rule |
|---|---|---|
| itemName (Item) | item |  |
| itemSlot (Item Slot) | select | dom:{'0': {}, '1': {}, '10': {}, '11': {}, '12': {}, '13': {}, '14': {}, '15': {}, '16': {}, '17': {}, '18': {}, '19': {}, '2': {}, '3': {}, '5': {}, '6': {}, '7': {}, '8': {}, '9': {}} |
| inverse (Inverse) | toggle |  |

## Item Type Equipped  - progress: none
| lever | type | rule |
|---|---|---|
| itemTypeName (Item Type) | multiselect |  |

## Weapon Enchant  - progress: timed
| lever | type | rule |
|---|---|---|
| weapon (Weapon) | select | dom:{'main': {}, 'off': {}, 'ranged': {}} |
| enchant (Weapon Enchant) | string |  |
| stacks (Stack Count) | number |  |
| remaining (Remaining Time) | number |  |
| showOn (Show On) | select |  |
