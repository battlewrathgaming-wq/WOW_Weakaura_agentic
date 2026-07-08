# Bloodmage - color palette (light note)

Observed hex values, NOT authority. Captured from a real Battlewrath
in-game export decoded via `weakaura_codec.py` (2026-07-07). These are a
reference palette to reason against while exploring contrast - nothing here
is a locked/absolute value, and `inventory.py` was deliberately NOT
rewritten from these (its build-time colors stay as-is until Battlewrath
says otherwise). Treat as "what a real tuning pass looked like at one
moment," not a spec.

## Anchor

- **Divider strip** `#C6000E` (`[0.7765, 0, 0.0549, 1]`) - the harshest,
  most saturated red, intended as the fixed reference point; every other
  bar is meant to pull contrast off this so the panel doesn't read as one
  flat red.

## Resource bars (observed)

- **HP Reserve** - a **horizontal gradient**, not a solid fill
  (`enableGradient: true`, `gradientOrientation: HORIZONTAL`):
  - `barColor` `#751117` (`[0.4588, 0.0667, 0.0902, 1]`) - deep
    oxblood/maroon (the darker end).
  - `barColor2` `#D95D6D` (`[0.8510, 0.3647, 0.4275, 1]`) - lighter rose
    (the brighter end).
  - Good contrast against the anchor already (dark maroon vs. the bright
    divider). The gradient is a manual tickbox + `barColor2` field on the
    WeakAuras end today; folding it into the auto-build is a small later
    core tweak (health template + a `bar_color2` arg on `health_slot`),
    parked until the look is locked - not worth formalizing yet.
- **Rage** `#C40011` (`[0.7686, 0, 0.0667, 1]`) - bright red.

## Timer bars (unchanged from template defaults)

- **Cast Bar** `#9ED9FF` (light blue) - cool, reads as "timer" vs. the
  left column's reds.
- **Swing Timer** `#FFFFFF` (white).
- **Cast/Swing backing plates** `#FFFFFF` white bar over a translucent
  black background - standard.

## Contrast note (for a later tuning pass, not acted on)

Rage `#C40011` and the divider `#C6000E` are nearly identical - they will
blend in-game. Biggest opportunity to separate them without leaving the
blood palette: keep the divider as the harsh anchor, pull Rage darker
and/or a notch desaturated so the seam still pops. HP Reserve's maroon vs.
the anchor is already a clean separation. The right (timer) column reading
cool/neutral vs. the left (resource) column reading red is a useful
built-in axis to preserve.

## Build-time values currently in `inventory.py` (for reference)

These are what a rebuild produces today - intentionally left in place, not
overwritten by the capture above:
- HP Reserve: theme accent `#c66161` (`ACCENT_COLOR`), solid fill (the
  live gradient is set manually on the WeakAuras end, not auto-built yet).
- Rage: `RAGE_BAR_COLOR` `[0.77, 0.25, 0.25, 1]` (flagged placeholder,
  Blizzard's canonical Rage red).
- Divider: theme accent `#c66161`.
