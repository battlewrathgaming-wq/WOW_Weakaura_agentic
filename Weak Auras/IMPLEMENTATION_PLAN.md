# Implementation plan: clearing the stock UI

Scope: the addon-level work to get default Blizzard UI elements (starting
with action bars) out of the way, making room for the WeakAuras HUD
described in `HUD_DESIGN.md`. This is a different track from
`AURA_BLUEPRINT.md`, which is the per-element method for the WeakAuras HUD
content itself, once this clearing work is done. Nothing in this doc has
been tested in-game yet.

## Current state (2026-07-02, updated same day)

- Addons confirmed installed (`Interface/AddOns`): the WeakAuras suite
  (v5.21.2), MoveAnything (v11.b2, WotLK-compatible), and **Bartender4**
  (v4.4.2, WotLK-compatible - confirmed via its own `.toc`).
- **Decision: skipped the static-dim step and went straight to Bartender4**,
  called out as the easier addon to work with. The original plan (static-
  dim via MoveAnything first, Bartender4 only as a fallback) is superseded
  - see "Revised step 1" below.
- MoveAnything stays installed, but its role shifts: instead of dimming the
  action bars themselves (Bartender4's job now), it's the tool for
  repositioning/hiding whatever other stock frames Bartender4 doesn't touch
  (minimap, XP bar, etc.) - the original reasoning for pairing the two.
- **A live realm and test character now exist**: character `Weakauratest`
  on realm `Area 52 - Free-Pick` (distinct from the earlier offline
  `Vol'jin - Stress Test` realm characters). Confirmed on disk - the
  character has logged in at least once (cache/chat-cache/config files
  exist). This is the first real opportunity to test anything in this plan
  and the WeakAuras injection-stability question from `USE_CASE.md`.
- One thing worth checking on next login: this character's `AddOns.txt`
  snapshot shows `WeakAurasCompanion` and `WeakAurasArchive` enabled, but
  not the main `WeakAuras` addon, `Bartender4`, or `MoveAnything` - likely
  just because the list predates those being added/swapped, but worth
  confirming all three actually show enabled in the in-game AddOns screen
  before assuming they're active for this character.

## Revised step 1: Configure Bartender4 on the stock action bars

- Bartender4 replaces the default Blizzard action bars directly (no
  MoveAnything conflict, since MoveAnything was never configured against
  them - nothing to unwind).
- Set up the mouseover-fade/hide behavior natively in Bartender4's own
  config (right-click on a bar or its options panel) rather than through a
  second addon - this was the actual point of preferring it over the
  static-dim compromise.
- Once configured, note the settings used here (which bars, fade
  threshold/delay, alpha values) so it's reproducible without relying on
  memory or this character's SavedVariables alone.

## Step 2: Live-test on Weakauratest / Area 52 - Free-Pick

- Now possible, given the live character above. Confirm: Bartender4's
  fade-on-mouseover actually behaves as expected, bars don't conflict with
  Ascension's own custom UI panels, and note anything Ascension-specific
  that standard Bartender4 guidance wouldn't anticipate.
- This is also the natural place to test the WeakAuras injection-stability
  question from `USE_CASE.md`, since a live character with WeakAuras
  installed now exists - worth doing both checks in the same session.

## Swing timer - no new addon dependency needed (checked, then withdrawn, 2026-07-06)

First pass concluded a real swing timer aura would need **SwingTimerAPI by
Ralgathor** as a new addon, based on a live Wago pack stating that
dependency. Battlewrath questioned that (correctly) - it would've meant
this was the one HUD element forcing an extra library on anyone who wants
it, unlike everything else here. Reading the actual installed WeakAuras
source (`Prototypes.lua`) directly instead of trusting one pack's stated
requirement showed WeakAuras has its own fully native **Swing Timer**
trigger type (`WeakAuras.InitSwingTimer()`/`GetSwingTimerInfo(hand)`,
internal to the addon, supporting main/off/ranged) - see
`CAPABILITY_INVENTORY.md`'s verified entry and `HUD_DESIGN.md`'s
Resources-tier writeup. **No new addon needed** - the current addon list
below (Bartender4, MoveAnything) is unaffected.

## Relationship to the rest of the project

This plan only clears space - it doesn't touch HUD content. The actual
tiered HUD (`HUD_DESIGN.md`) still depends on the ability-index pipeline
(Necromancer only so far) and the WeakAuras injection-stability question,
both tracked in `USE_CASE.md`. This track can proceed in parallel and
independent of those blockers, since it's addon configuration, not
WeakAuras authoring.
