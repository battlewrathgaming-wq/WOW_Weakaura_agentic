# spell - routing index
_Main (input) levers only. Open `spell.json` for full handling. rule: `array`=multiEntry (value+operator as arrays) - `dom:X`=value-domain X (see domains.json)._

## Action Usable  - progress: none
| lever | type | rule |
|---|---|---|
| spellName (Spell) | spell |  |
| targetRequired (Require Valid Target) | toggle |  |
| ignoreSpellCooldown (Ignore Spell Cooldown/Charges) | toggle |  |
| charges (Charges) | number |  |
| spellCount (Spell Count) | number |  |
| inverse (Inverse) | toggle |  |

## Charges Changed  - progress: timed
| lever | type | rule |
|---|---|---|
| spellName (Spell) | spell |  |
| direction (Charge gained/lost) | select | dom:{'CHANGED': 'Changed', 'GAINED': 'Gained', 'LOST': 'Lost'} |
| charges (Charges) | number |  |

## Cooldown Progress (Spell)  - progress: timed
| lever | type | rule |
|---|---|---|
| spellName (Spell) | spell |  |
| extra Cooldown Progress (Spell) (<function>) | collapse |  |
| track (Track Cooldowns) | select | dom:{'auto': 'Auto', 'charges': 'Charges', 'cooldown': 'Cooldown'} |
| showgcd (Show Global Cooldown) | toggle |  |
| matchedRune (Ignore Rune CD) | toggle |  |
| ignoreSpellKnown (Disable Spell Known Check) | toggle |  |
| trackcharge (Show CD of Charge) | number |  |
| remaining (Remaining Time) | number |  |
| charges (Charges) | number |  |
| spellCount (Spell Count) | number |  |
| genericShowOn (Show) | select | dom:{'showAlways': 'Always', 'showOnCooldown': 'On Cooldown', 'showOnReady': 'Not on Cooldown'} |

## Cooldown Ready (Spell)  - progress: timed
| lever | type | rule |
|---|---|---|
| spellName (Spell) | spell |  |

## Global Cooldown  - progress: timed
| lever | type | rule |
|---|---|---|
| inverse (Inverse) | toggle |  |

## Queued Action  - progress: none
| lever | type | rule |
|---|---|---|
| spellName (Spell) | spell |  |

## Spell Known  - progress: none
| lever | type | rule |
|---|---|---|
| spellName (Spell) | spell |  |
| petspell (Pet Spell) | toggle |  |
| inverse (Inverse) | toggle |  |

## Totem  - progress: timed
| lever | type | rule |
|---|---|---|
| totemType (Totem Number) | select | dom:['Fire', 'Earth', 'Water', 'Air'] |
| totemName (Totem Name) | string |  |
| totemNamePattern (Totem Name Pattern Match) | longstring |  |
| icon (Totem Icon) | number |  |
| inverse (Inverse) | toggle |  |
| clones (Clone per Match) | toggle |  |
| remaining (Remaining Time) | number |  |
