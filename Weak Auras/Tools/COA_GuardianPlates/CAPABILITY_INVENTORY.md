# Nameplate addon capability inventory (Phase 1 of GuardianPlates expansion)

Code review of the 4 nameplate addons currently installed alongside
COA_GuardianPlates, done to identify capabilities worth reshaping into small,
independently-toggleable GuardianPlates features rather than adopting any of
these addons' "everything at once" surface area.

## TurboPlates (by surm) - the "everything, with filters" addon

The most feature-dense of the four; this breadth is exactly what "information
overload" means in practice. Full settings surface (`Config.lua`, 1117 lines)
covers: general visibility (friendly/enemy/pets/guardians/totems), nameplate
style, name/health text formats, colors, castbars, debuffs, buffs, personal
resource bar, combo points, TurboDebuffs, mob indicators (elite/boss icon
styles, level indicators), plate stacking (anti-overlap), and profiles.

Three pieces stand out as genuinely reusable shapes, not just "more options":

- **Tank Mode** (`tankMode = 0/1/2`: Disabled/Smart/Always On) - distinct
  health-bar color schemes for tank-holding-threat vs DPS/healer-view of the
  same fight: `secureColor`/`transColor`/`insecureColor`/`offTankColor` for
  tanks (has aggro / losing it / doesn't have it / another tank has it) vs
  `dpsSecureColor`/`dpsTransColor`/`dpsAggroColor` for everyone else. Role
  literally changes what color means on the same bar.
- **Threat Text** - a separate small text display anchored near the health
  bar, independent of the color scheme above. Shows the number, not just the
  color.
- **TurboDebuffs** (`TurboDebuffs.lua`) - a BigDebuffs-style curated display:
  instead of "show every debuff," it sorts every debuff into one of 10 fixed
  mechanic categories (Immunities, CC, Silence, Interrupts, Roots, Disarm,
  Defensive/Offensive/Other Buffs, Snares), each independently toggleable and
  carrying its own display-priority value (Immunities 80 down to Interrupts
  25) so when multiple apply, the most important one wins the display slot.
  This is the clearest existing "avoid overload via curation" pattern in any
  of the four addons - curation by mechanic category, not by addon-maintained
  spell list.
- **Healer Detection** (`HealerDetection.lua`) - PvP-zone-only (arena/BG),
  combat-log-driven: watches for casts of a fixed list of healer-only talent
  spells (e.g. Penance, Swiftmend, Riptide, Holy Shock) and marks any GUID
  that casts one as a healer for the rest of the zone, with a small icon
  overlay. Notable as a *reactive, combat-log-based* role-detection method,
  distinct from Kui's talent-point method below - relevant prior art if
  GuardianPlates ever wants PvP-specific behavior, but out of scope for the
  current PvE per-role goal.

## Kui_Nameplates - explicit role modules, talent-based detection

Filenames are already organized by role concept (`TankMode.lua`,
`CastWarnings.lua`, `LowHealth.lua`). Read `TankMode.lua` in full:

- **Role detection is talent-point-based, not spec-tab-based**: rather than
  just checking `GetActiveTalentGroup()`, it inspects specific talent point
  investment per class to decide Tank vs Healer vs Damager - e.g. Warrior
  Protection tab ≥51 points, Paladin Protection ≥51, Druid Feral tab ≥51
  *and* a 4-talent tank-signature check (Natural Reaction, Thick Hide,
  Survival Instincts, Protector of the Pack ≥3 combined), Death Knight via a
  3-talent tank-signature check (Anticipation, Toughness, Blade Barrier).
  This is meaningfully more precise than "which talent tree has the most
  points" and directly useful groundwork for GuardianPlates' own deferred
  "spec-aware auto-toggle" item, whenever that gets picked up later.
- **Smart / Disabled / Always-on tri-state** for tank mode, same shape as
  TurboPlates' `tankMode` setting - two independent addons converging on the
  same 3-way toggle design is a signal this is the right default shape.
  "Smart" mode also re-evaluates live on `PLAYER_TALENT_UPDATE` and (for
  Warriors specifically) `UPDATE_SHAPESHIFT_FORM`, since Warriors can't tank
  in Gladiator Stance.
  - Also confirms Warrior/Paladin/Druid/DK have canonical tank specs, and
    Paladin/Shaman/Druid/Priest(Disc) have canonical healer specs, per
    `IsHealer()`'s own logic - useful as a settled reference if GuardianPlates
    ever needs its own per-class role table.
- **Threat brackets** - a separate cosmetic option (corner-bracket textures
  around the health bar) that inherits the tank-mode bar color when tank mode
  is active, or the default UI glow color otherwise. A second, independent
  on/off toggle layered on top of tank mode rather than bundled into it -
  another instance of "one capability, one switch" worth copying directly.

## Kui_Nameplates_Auras - pre-curated per-class spell list, user-editable

Uses a shared library (`KuiSpellList-1.0`) providing a maintained default
"important spells per class" list, rather than showing every aura. The
options UI (`Config.lua`, fully read) lets the user see the default list for
any class side-by-side with a custom list, right-click a default entry to
ignore it, or add extra spells by ID or verbatim name to a custom list. Two
curation lessons:

- The *default* curated list is opinionated and shipped by the addon author,
  not built by the end user from scratch - the user only needs to prune/add
  at the margins.
  the margins.
- Ignore-list and add-list are stored and applied per class, since "what
  matters" genuinely differs by class matchup, not just by role.

## PlateBuffs - reactive, learn-as-you-go curation

No pre-built spell list at all. Instead it watches the combat log
(`watchCombatlog`), auto-discovers every spell it sees applied to a
nameplate, and adds it to a running per-spell settings table
(`P.spellOpts[name]`) with a default show rule of **Always / Mine only /
Never** (`options.lua`, fully read) - global defaults
(`defaultBuffShow`/`defaultDebuffShow`) start most buffs at "None" and most
debuffs at "Mine only," and the user then promotes/demotes specific spells
once they've actually been seen in play. This is the opposite discovery
model from Kui's pre-curated list: curation happens after the fact, driven
by what you've actually encountered, rather than a static list shipped in
advance.

- Also has straightforward reaction/unit-type filters (players/NPCs,
  friendly/neutral/hostile, totems on/off) and a "combat only" filter per
  unit type (`npcCombatWithOnly`/`playerCombatWithOnly`) - suppresses buff
  icons on units not in combat, a cheap noise-reduction lever distinct from
  spell-level curation.

## Three distinct curation philosophies, for Phase 3 reference

1. **Fixed mechanic categories with priority** (TurboPlates TurboDebuffs) -
   good fit for "always show the scariest thing happening to this unit,"
   doesn't need per-spell maintenance.
2. **Pre-curated per-class list, user-editable** (Kui_Nameplates_Auras) -
   good fit for "this addon should ship an opinionated default," needs
   ongoing maintenance as new content/talents ship.
3. **Reactive/learn-as-you-go per-spell** (PlateBuffs) - good fit for a
   small private-server population where the "important spell" list isn't
   well known in advance and will differ boss-to-boss; zero maintenance
   burden but noisy until the user has tuned it.

For a *light* GuardianPlates extension aimed at per-character selection (no
profiles/specs yet), (1) and (2) are the more promising shapes: fixed,
small, independently-toggleable categories match the "per-capability on/off
selector" the user asked for, without needing a maintained mega-list or a
learn-as-you-go tuning phase before it's useful.

## Capabilities worth taking the shape of, going into Phase 2/3

- Tank/DPS/healer-differentiated health-bar coloring, tri-state
  (Off/Smart/Always), talent-point-based smart detection (Kui's method is
  more precise than spec-tab-only).
- A small number of fixed, independently-toggleable "mechanic" categories
  for debuffs (start much smaller than TurboPlates' 10 - e.g. just
  CC/Interrupts/Defensive cooldowns as a v1), each with its own on/off
  switch, no priority system needed yet at this scale.
- Threat brackets or an equivalent lightweight visual cue as an optional
  layer independent of the color scheme itself.
- Explicitly *not* adopting: full aura tracking of every buff/debuff, combo
  points, personal resource bar, plate stacking physics, mob-indicator icon
  styles, quest objective icons - these are already well covered by other
  installed addons (ShadowedUnitFrames, WeakAuras, etc.) or add UI surface
  area GuardianPlates doesn't need to own.

Next: Phase 2 research on what tanks/healers/DPS communities actually say
they rely on seeing on nameplates, to sanity-check which of the above are
worth building first.
