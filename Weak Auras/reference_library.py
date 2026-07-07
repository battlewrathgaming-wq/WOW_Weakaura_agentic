"""
reference_library.py - Real WeakAuras structures pulled from a public,
free community export, kept as reference material for our own aura design
- not to copy wholesale, but to see how an experienced pack author actually
solves anchoring, section naming, and glow/texture techniques in practice.

PROOF OF CONCEPT (2026-07-02)
-----------------------------
Source: "Fojji - Class Pack Anchors [Classic]"
  https://wago.io/FojjiClassAnchors-Classic
  Author: Fojji (https://wago.io/p/Fojji, https://www.patreon.com/fojjiwow)
  TBC-WEAKAURA, v1.1.1-4, free/public - no login or payment required to
  view or copy the import string.

IMPORTANT - what this is and isn't:
  Fojji's actual "Class Packs" (the fully-realized per-class rotation
  auras) are Patreon-gated content, not accessed here. What IS free and
  public is this "Anchors" pack: a skeleton of named, empty/placeholder
  Dynamic Groups whose only real job is to mark WHERE each class pack's
  sections get positioned on screen - "Move the sub-groups where you want
  things positioned for my Class Packs... only the first level sub-group
  will matter, the rest is preview only" (from the pack's own
  description). So nearly everything captured below is positioning/naming
  scaffolding, not live trigger logic - several leaf regions here have
  alpha=0 and cooldown/icon disabled, i.e. they are literally invisible
  placeholders, not functioning auras. That's fine for our purpose: we
  wanted a structural reference (anchor hierarchy, section taxonomy,
  visual technique choices), not tracking logic to copy.

  Pulled via wago.io's own in-browser Editor tab (Monaco), which renders
  the already-decoded table server-side - no need to run this project's
  weakaura_codec.py decoder for this particular capture, though the data
  shape is identical to what that decoder produces from an import string.

DISCOVERY: group-export envelope shape (relevant to weakaura_codec.py)
-----------------------------------------------------------------------
weakaura_codec.py's encode/decode_import_string only handles the
single-aura envelope: {"m": "d", "d": <aura table>, "v": ..., "s": ...}.
This pack's real export is a GROUP (a Dynamic Group with child auras), and
its envelope shape is different - confirmed directly from the real page
data:

    {
        "m": "d",
        "d": <the group's own table - anchorPoint, controlledChildren
              (list of child ids), etc.>,
        "c": [ <child aura table>, <child aura table>, ... ],  # 85 of them
        "v": <version int>,
        "s": <WeakAuras version string>,
        "wagoID": <wago.io's own tracking id - not a WeakAuras field>,
    }

i.e. for a group export, the children live in a sibling top-level "c"
array, not nested inside "d". weakaura_codec.py's decode_import_string
would currently raise on this shape (its "m"=="d" check passes, but it
throws away anything besides "d"). Not fixed yet - flagging as a known
gap for whenever we need to decode/encode a *group* aura rather than a
single one. Single-aura encode/decode (our actual current use case, per
AURA_BLUEPRINT.md's one-tier-at-a-time approach) is unaffected.

HOW TO USE THIS FILE
---------------------
Skim FOJJI_SECTION_TAXONOMY first - it's the highest-value find: a real,
shipped section list for a "clear the default UI, replace with custom
HUD" class pack, which is exactly our own USE_CASE.md goal. Compare it
against HUD_DESIGN.md's five tiers before building new auras, to borrow
naming/grouping ideas rather than reinventing them from nothing.

Then look at FOJJI_CORE_ANCHOR_GROUP and FOJJI_PROC_TEXTURE_GROUP for two
different real anchoring/visual patterns, and SWING_TIMER_STUB for a
minimal bar-region skeleton.
"""

# ============================================================================
# 1. Section taxonomy - the named children of the top-level anchor group
# ============================================================================
#
# This is the actual `controlledChildren` list of the top-level "Fojji -
# Class Pack Anchors [Classic]" Dynamic Group - i.e. the real section
# breakdown Fojji ships for every class pack. Compare against
# HUD_DESIGN.md's five tiers:
#
#   HUD_DESIGN.md tier          ->  Closest Fojji section(s)
#   proc/condition (innermost)  ->  "Proc Textures", "Pop-up Group"
#   rotation                    ->  "Core", "Extra Icons"
#   power-button                ->  "Defensive CDs", "Defensive",
#                                    "Base Cooldowns", "Base CDs [Healer]",
#                                    "Cooldown Bar"
#   HP/resources (outermost-in) ->  "Powers"
#   consumable/prep footer      ->  "Reminders"
#   (not in our model yet)      ->  "Player Cast Bar", "Target Cast Bar",
#                                    "Texts", "SwingTimerAPI"
#
# Two real gaps this surfaces in our own model: cast bars (player/target)
# aren't covered by any of our five tiers, and "Pop-up Group" suggests
# Fojji treats transient/rare procs as a distinct pop-in layer rather than
# folding them into the main proc tier - worth a follow-up discussion.
FOJJI_SECTION_TAXONOMY = [
    "SwingTimerAPI",
    "Fojji Anchors - Player Cast Bar [Class]",
    "Fojji Anchors - Target Cast Bar [Class]",
    "Fojji Anchors - Base Cooldowns [Class]",
    "Fojji Anchors - Base CDs [Healer] [Class]",
    "Fojji Anchors - Cooldown Bar [Class]",
    "Fojji Anchors - Core [Class]",
    "Fojji Anchors - Defensive CDs [Class]",
    "Fojji Anchors - Defensive [Class]",
    "Fojji Anchors - Extra Icons [Class]",
    "Fojji Anchors - Pop-up Group [Class]",
    "Fojji Anchors - Powers [Class]",
    "Fojji Anchors - Proc Textures [Class]",
    "Fojji Anchors - Reminders [Class]",
    "Fojji Anchors - Texts [Class]",
]


# ============================================================================
# 2. Nested anchor pattern - "Core" section, trimmed
# ============================================================================
#
# Real fields from "Fojji Anchors - Core [Class]" (a second-level Dynamic
# Group, parented to the top-level pack). Boilerplate fields with no
# structural signal (actions/authorOptions/config/conditions/information/
# animation - all empty or default in this pack) are omitted for
# readability; nothing was altered otherwise.
#
# The interesting part is `controlledChildren`: three THIRD-level groups,
# each named "DON'T MOVE - ...". That naming convention - not a WeakAuras
# feature, just a human one - is the real find here: it's how Fojji
# communicates our own "fixed channels" rule (HUD_DESIGN.md) to end users
# editing the pack by hand. A literal in-editor label warning people not
# to break the anchor contract. Worth borrowing verbatim for our own
# groups once we're building real multi-person-shared auras.
FOJJI_CORE_ANCHOR_GROUP = {
    "id": "Fojji Anchors - Core [Class]",
    "regionType": "group",
    "parent": "Fojji - Class Pack Anchors [Classic]",
    "controlledChildren": [
        "DON'T MOVE - Power Bars",
        "DON'T MOVE - Spec - Main Bar",
        "DON'T MOVE - Spec - Additions",
    ],
    "anchorFrameType": "SCREEN",
    "anchorPoint": "CENTER",
    "frameStrata": 1,
    "groupIcon": "Interface\\AddOns\\FojjiCore\\textures\\FojjiBlue.tga",
    "border": False,
    "borderBackdrop": "Blizzard Tooltip",
    "borderColor": [0, 0, 0, 1],
    "borderEdge": "Square Full White",
    "borderInset": 1,
    "borderOffset": 4,
    "borderSize": 2,
    "backdropColor": [1, 1, 1, 0.5],
    "alpha": 1,
}


# ============================================================================
# 3. Alternate proc-glow technique - texture regions, not icon regions
# ============================================================================
#
# Our own EXAMPLE_TEST_AURA (weakaura_codec.py) used regionType "icon" with
# a "subglow" sub-region for its proc-style visual. Fojji's proc-texture
# slots use a completely different, older WeakAuras technique instead:
# regionType "texture" with separate foreground/background texture layers,
# crop_x/crop_y, and blendMode - the classic "Power Auras"-style full-
# screen or large glow effect (note the actual texture path reused from
# the bundled WeakAuras "PowerAurasMedia" folder, a holdover library of
# proc-glow art assets most WeakAuras installs ship with).
#
# Structurally: a "Proc Textures" group containing three near-identical
# leaf slots (1/2/3) - i.e. Fojji reserves three simultaneous glow slots
# up front rather than dynamically spawning them, presumably so the
# anchor positions stay fixed regardless of which proc is active. That's
# another concrete instance of our own "fixed channels" principle.
FOJJI_PROC_TEXTURE_GROUP = {
    "id": "Fojji Anchors - Proc Textures [Class]",
    "regionType": "group",
    "parent": "Fojji - Class Pack Anchors [Classic]",
    "controlledChildren": [
        "Fojji Anchor - Proc Texture 1",
        "Fojji Anchor - Proc Texture 2",
        "Fojji Anchor - Proc Texture 3",
    ],
    "anchorFrameType": "SCREEN",
    "anchorPoint": "CENTER",
    "frameStrata": 1,
    "scale": 1,
    "selfPoint": "CENTER",
}

# One of the three leaf slots (a placeholder, alpha=0 - see module
# docstring on why most leaves here are invisible stubs). Trimmed the
# same way as above.
FOJJI_PROC_TEXTURE_LEAF_EXAMPLE = {
    "id": "Fojji Anchor - Proc Texture 1",
    "regionType": "texture",
    "anchorFrameType": "SCREEN",
    "anchorPoint": "CENTER",
    "alpha": 1,
    "frameStrata": 2,
    "height": 40,
    "auraRotation": 0,
    "blendMode": "BLEND",
    "compress": False,
    "crop_x": 0.4,
    "crop_y": 1,
    "backgroundColor": [0.5, 0.5, 0.5, 0.5],
    "backgroundOffset": 2,
    "backgroundTexture": "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura3",
    "desaturateBackground": False,
    "desaturateForeground": False,
    "foregroundColor": [0.8156862745098, 0.8156862745098, 0.8156862745098, 1],
    "foregroundTexture": "Interface\\AddOns\\FojjiCore\\textures\\rime.blp",
    "font": "Friz Quadrata TT",
    "fontSize": 12,
    "inverse": False,
    "load": {
        "class": {"multi": {"DEATHKNIGHT": True}, "single": "DEATHKNIGHT"},
        "race": [],
        "size": {"multi": []},
        # "spec" truncated in capture - present but not read for this POC
    },
}


# ============================================================================
# 4. Minimal bar-region skeleton - swing timer placeholder
# ============================================================================
#
# "SwingTimerAPI" - also an invisible placeholder (alpha 0, cooldown/icon
# both disabled) but useful purely as a skeleton of what a real WeakAuras
# progress-bar region's fields look like (as opposed to the icon-region
# shape our EXAMPLE_TEST_AURA already documents in weakaura_codec.py).
# Notably: this is a section HUD_DESIGN.md doesn't have a tier for yet -
# cast/swing timing - which only surfaced because we looked at a real
# shipped pack instead of designing top-down.
SWING_TIMER_STUB = {
    "id": "SwingTimerAPI",
    "regionType": None,  # not captured in this trimmed pull - bar-style
                          # region inferred from automaticWidth/barColor/
                          # fixedWidth/cooldownSwipe fields below
    "alpha": 0,
    "anchorFrameType": "SCREEN",
    "anchorPoint": "CENTER",
    "automaticWidth": "Auto",
    "fixedWidth": 200,
    "height": 30,
    "backgroundColor": [0, 0, 0, 0.5],
    "barColor": [1, 0, 0, 1],
    "color": [1, 1, 1, 1],
    "cooldown": False,
    "cooldownEdge": False,
    "cooldownSwipe": True,
    "customTextUpdate": "event",
    "displayIcon": "136243",
    "displayText": "%p",
    "displayText_format_p_format": "timed",
    "displayText_format_p_time_dynamic_threshold": 60,
    "displayText_format_p_time_format": 0,
    "displayText_format_p_time_precision": 1,
    "font": "Friz Quadrata TT",
    "fontSize": 12,
    "icon": False,
    "icon_side": "RIGHT",
    "inverse": False,
}


# ============================================================================
# 6. Second source: Luxthos - Mage (Classic Era) - scale/material research
# ============================================================================
#
# Source: "Luxthos - Mage (Classic Era)"
#   https://wago.io/LuxthosMageClassicEra
#   Author: Luxthos (https://wago.io/p/Luxthos, https://www.luxthos.com)
#   CLASSIC-WEAKAURA, v1.15.1-2, s="5.18.1", free/public. Pulled 2026-07-02
#   specifically to check real scale/readability/material conventions
#   after the Template_shadow scaffold discussion raised "what already
#   looks nice" as an open question - see USE_CASE.md's "Scale,
#   readability, and material quality" section for the write-up this data
#   backs. Chosen over a WotLK-specific pack because Luxthos's WotLK line
#   is confirmed discontinued (luxthos.com's own WotLK archive is empty);
#   Classic Era is their actively maintained old-ruleset line and a
#   reasonable stand-in per the same reasoning as Fojji above.
#
# Section taxonomy (top-level group's controlledChildren, 10 sections):
#   Class Options, General Options, Mana Tick, Dynamic Effects, Core,
#   Left Side, Right Side, Utilities, Maintenance, Resources
# This is a genuinely different breakdown from Fojji's 15-section list
# (no "Proc Textures"/"Pop-up Group" naming, no explicit power-button/
# defensive split) - worth treating as a second, independent data point
# rather than assuming either taxonomy is "the" convention.
LUXTHOS_MAGE_SECTIONS = [
    "Class Options - LWA - Mage",
    "General Options - LWA - Mage",
    "Mana Tick - LWA - Mage",
    "Dynamic Effects - LWA - Mage",
    "Core - LWA - Mage",
    "Left Side - LWA - Mage",
    "Right Side - LWA - Mage",
    "Utilities - LWA - Mage",
    "Maintenance - LWA - Mage",
    "Resources - LWA - Mage",
]

# Real per-region size/font/texture data pulled directly from the decoded
# export (not approximated). This is the actual payoff of checking a
# second source: it CONTRADICTS part of what the ToxiUI integration guide
# suggested (see USE_CASE.md), rather than just confirming it - both are
# real, currently-popular choices, so treat this as "at least two valid
# conventions exist," not "here is the one right answer":
#
#   - Every ability icon (Core, Utilities, Maintenance, Dynamic Effects)
#     is a uniform 48x48 SQUARE, regardless of section/tier. No 4:3
#     aspect-ratio variation by category the way ToxiUI's guide
#     described. Hierarchy between tiers here is conveyed entirely by
#     POSITION/GROUPING, not by icon size - a real, different answer to
#     the "scale and position together" question Battlewrath raised.
#   - The three main state bars (Health/Mana/Cast, in "Resources") are
#     405 wide x 20 tall, "Solid" texture, "Friz Quadrata TT" font (the
#     plain default WoW UI font, not a custom LibSharedMedia font like
#     Expressway - contradicts the "Expressway is the go-to" community
#     claim from the earlier research pass, at least for this pack).
#   - "Mana Tick" (a separate proc/timing helper bar, distinct from the
#     main Mana bar above) is a much thinner 200x10 strip - so within
#     ONE pack there's already a real precedent for "the same kind of
#     region (aurabar) gets very different visual weight depending on
#     whether it's primary state or a secondary timing helper," which
#     lines up with ToxiUI's "bars are thin accents, not heavy blocks"
#     finding even though the icon-sizing finding didn't line up.
#   - Borders/textures lean plain: "ElvUI Blank" backdrop (a common
#     shared borderless/minimal backdrop name, not a custom border
#     texture) and "Solid" fill - reinforces the "clean reads as
#     plain/thin, not elaborate" signal from the first research pass.
LUXTHOS_MAGE_RESOURCE_BARS = {
    "Health Bar - LWA - Mage": {"regionType": "aurabar", "width": 405, "height": 20, "texture": "Solid", "font": "Friz Quadrata TT"},
    "Mana Bar - LWA - Mage": {"regionType": "aurabar", "width": 405, "height": 20, "texture": "Solid", "font": "Friz Quadrata TT"},
    "Cast Bar - LWA - Mage": {"regionType": "aurabar", "width": 405, "height": 20, "texture": "Solid", "font": "Friz Quadrata TT"},
    "Mana Tick - LWA - Mage": {"regionType": "aurabar", "width": 200, "height": 10, "texture": "Solid", "borderBackdrop": "ElvUI Blank"},
}

# Every leaf ability icon sampled across Core/Utilities/Maintenance/
# Dynamic Effects came back identical: 48x48, square. Listed as one
# representative rather than duplicating the same {w:48,h:48} 20+ times.
LUXTHOS_MAGE_ICON_SIZE = {"width": 48, "height": 48, "regionType": "icon"}


# ============================================================================
# 7. Cross-class "Core" (rotation+CD) icon-pool counts (2026-07-02)
# ============================================================================
#
# Pulled to answer Battlewrath's question: how many icons for the
# rotational side, given Power-button/major-CDs are already known to run
# 3-6? Checked the "Core" DynamicGroup child count across 3 Luxthos
# Classic Era class packs:
#
#   Mage (3 specs):   11 children
#   Warrior (3 specs): 18 children
#   Rogue (3 specs):   11 children
#
# IMPORTANT CAVEAT: every child in every "Core" group checked has
# load.spec.multi covering ALL of that class's specs (e.g. Mortal Strike,
# a pure-Arms ability, is still flagged spec 0/1/2 in Warrior's data) -
# these packs do NOT restrict visibility by spec by the Load tab. A
# DynamicGroup auto-hides children whose own trigger isn't currently
# active (spell unknown/not in your bars), so the real on-screen count
# for any ONE spec at a given moment is smaller than these raw pool
# sizes - the pool bundles all specs' abilities (and mixes rotation
# builders/finishers together with several CD-type abilities in the same
# "Core" group, not just pure rotation) into one static number. This data
# can't tell you the exact simultaneous on-screen count without either
# simulating a specific spec/talent build or checking the author's own
# screenshots - it's an upper-bound pool size, not a per-spec answer.
LUXTHOS_CORE_POOL_COUNTS = {
    "Mage (3 specs)": 11,
    "Warrior (3 specs)": 18,
    "Rogue (3 specs)": 11,
}


# ============================================================================
# 9. Real icon spacing, pulled from the actual live group (2026-07-02)
# ============================================================================
#
# Checked directly (not assumed) after Template_shadow v0.3's invented
# "gap = 25% of icon width" rule (10px on 40px icons) felt too loose live
# in-game. Pulled Luxthos Mage's "Core - LWA - Mage" group definition
# itself via wago.io's Editor/Monaco model - it's not a manually-
# positioned static Group at all, every leaf child has xOffset=yOffset=0;
# positioning is entirely delegated to WeakAuras' own DynamicGroup
# grow/space mechanism:
#
#   regionType: "dynamicgroup", grow: "CUSTOM" (a Lua growth function,
#   LWA.GrowCore), space: 2, columnSpace: 1, rowSpace: 1
#
# On 48x48 icons, that's roughly 4% of icon width - not a percentage
# that scales with size the way Template_shadow's v0.1-v0.3 gap formula
# assumed, but a small, close-to-fixed absolute value. This independently
# corroborates the ToxiUI integration guide's separately-documented ~2px
# spacing convention (see USE_CASE.md's scale/readability section) - two
# unrelated real packs both landing near a small fixed gap, not a
# proportional one. Superseded reasoning: Template_shadow's earlier
# "gap = round(icon_width * 0.25)" formula (USE_CASE.md, Template_shadow.py
# v0.1-v0.3) was an invented heuristic, not grounded in any real pack -
# this is the first actual measurement, and it says our gap was roughly
# 5x too generous.
LUXTHOS_CORE_GROUP_SPACING = {
    "regionType": "dynamicgroup",
    "icon_size": 48,
    "space": 2,
    "columnSpace": 1,
    "rowSpace": 1,
    "grow": "CUSTOM",
}


# ============================================================================
# 8. Open follow-ups this proof of concept surfaced
# ============================================================================
#
# - Cast bars (player/target) and a swing timer are real sections in a
#   shipped pack with no equivalent tier in HUD_DESIGN.md yet. Worth a
#   short discussion pass: are these in scope for Battlewrath's HUD, and
#   if so where do they sit relative to the five existing tiers? (Now
#   doubly confirmed - Luxthos's pack also has a dedicated Cast Bar in
#   Resources, independent of Fojji's Player/Target Cast Bar sections.)
#   RESOLVED 2026-07-06 - see HUD_DESIGN.md's Resources-tier section for
#   the full writeup: Player Cast Bar joins Resources (Luxthos's
#   convention, not Fojji's separate-section one), built with the same
#   Cast trigger `enemy_cast` already uses, just pointed at the player.
#   Swing timer: first pass concluded it needed a separate library addon
#   (SwingTimerAPI by Ralgathor - referenced by a live Wago "[WotLK] Swing
#   Timer" pack, 636 installs), since WeakAuras' own docs didn't seem to
#   cover it. Battlewrath pushed back on shipping the one HUD element that
#   would force an extra addon on anyone using it - reading the real
#   installed WeakAuras source directly (`Prototypes.lua`) instead of
#   trusting one pack's stated dependency reversed the conclusion: there's
#   a fully native "Swing Timer" trigger type, no external library
#   involved at all. See `CAPABILITY_INVENTORY.md`'s verified entry.
#   No addon changes needed in `IMPLEMENTATION_PLAN.md` after all.
# - "Pop-up Group" as a distinct section from "Proc Textures" suggests a
#   two-speed model for procs: routine ones live in the fixed proc tier,
#   rare/high-value ones pop in separately. Compare against our own
#   "adjacency by gameplay coupling" rule before deciding whether to
#   adopt this split.
# - The "DON'T MOVE - ..." naming convention is trivially adoptable now,
#   independent of any other decision - just a labeling habit for any
#   group whose position other auras anchor off of.
# - Uniform-square-icons (Luxthos) vs. per-category-4:3-icons (ToxiUI
#   guide) is now a genuinely open, evidence-backed choice rather than an
#   assumption either way - both are real, currently-popular. Worth
#   deciding by building both quickly and looking, same as the
#   scale/position question already flagged as "decide by feel."
# - Second source done (this section) - two independent packs now checked
#   (Fojji, TBC-Classic anchors-only; Luxthos, Classic Era full Mage
#   pack). A third source would help most specifically on the icon-size
#   question above, since the first two split evenly.
#
# ============================================================================
# 9. Phase 2 prior-art survey (2026-07-04) - Ascension-native sources
# ============================================================================
#
# Scoped by Battlewrath explicitly to include "odd balls" beyond the generic
# Classic-Era/Retail community conventions above: imp/pet management, target
# cast bar tracking, resource management, rotation helpers, a broad "what do
# people actually do with WeakAuras" survey, and - because Ascension's custom
# class/deployment architecture means generic WotLK research can't fully
# cover it - prior art from Ascension's OWN community specifically (forums,
# db.ascension.gg, its own database).
#
# --- The single most load-bearing finding: db.ascension.gg has a category
# literally named "Conquest of Azeroth" (?weakauras=200) - the same ruleset
# this project targets. Browsed live via Chrome (the listing page is
# JS-rendered, not reachable by plain fetch - same limitation as the Tinker
# class page in USE_CASE.md). Full catalog, 14 entries, all real and
# currently in use (view/install counts confirm actual adoption, not just
# uploads):
#
#   | Title | Author | Updated | Installs | What it covers |
#   |---|---|---|---|---|
#   | Bloodmage\|Qiuse\|CoA | user 1900 | 2026-03-18 | 32 | Bloodmage class, all specs |
#   | Creaky's Witch Hunter Suite | Creakydoors | 2026-01-07 | 41 | All 4 Witch Hunter specs, Load-gated |
#   | Creaky's Reaper Suite | Creakydoors | 2025-12-31 | 26 | All 3 Reaper specs, Load-gated |
#   | Auff's COA Lust / Raid Haste Reminder | Auffheimler | 2025-07-23 | 8 | Class-agnostic; more for classes with a raid-haste button; has instanced-content-specific logic |
#   | Monk All in One Tracker | Kobayashixd | 2023-06-15 | 68 | CD/stack trackers for every major spell, dynamic (Load-gated on what's learned) |
#   | Primary Resource Bars for CoA Classes | Kobayashixd | 2023-06-15 | 243 (highest of all 14) | Mana/Rage/Energy/Focus bars, shown per class via Load (author's own example: "Venomancers will show Rage and Mana, Starcallers will...") |
#   | HP/Mana/Stealth Indicator | Manofdreads | 2023-05-12 | 71 | Part of "Pvptrainerz's personal RM WA's for all specs, neatly grouped" (a 6-part personal suite - see next 5 rows) |
#   | Attunements | Manofdreads | 2023-05-12 | 42 | Attunements+Runes+Cosmic+Primordial - endgame progression tracking, not combat |
#   | Essences | Manofdreads | 2023-05-12 | 19 | Same suite |
#   | Salvos | Manofdreads | 2023-05-12 | 12 | Same suite |
#   | Shards | Manofdreads | 2023-05-12 | 7 | Same suite |
#   | Cards n Aces | Manofdreads | 2023-05-12 | 16 | Same suite |
#   | Spellslinger Aces Tracker by Catboy | Kobayashixd | 2023-05-08 | 10 | Spellslinger class, active-Aces display |
#   | Time Chronomancer WA by Catboy | Kobayashixd | 2023-04-26 | 64 | Orbs of Fate/Sands of Time/Upheaval stack counters, Bronze Protector CD, Rewind-during-Clone indicator |
#
#   Custom class names surfaced this way (cross-check against this project's
#   own 21-class roster next time it's handy): Bloodmage, Witch Hunter,
#   Reaper, Monk, Venomancer, Starcaller, Spellslinger, Time Chronomancer -
#   plus Necromancer and Tinker already known from USE_CASE.md's pet-tracking
#   research.
#
#   **Directly validates an existing design decision, not just background
#   color:** "Primary Resource Bars for CoA Classes" (243 installs, the most
#   popular entry in the whole category) is the real-world version of
#   HUD_DESIGN.md's Resources tier - two resource slots, contents
#   class-dependent, shown/hidden via Load rather than hand-built per class.
#   Same pattern independently confirmed on "Monk All in One Tracker" and
#   both Creakydoors suites ("Icons and trackers activate only after
#   talents/spells are learned"). This isn't a coincidence worth chasing
#   further - it's the standard, obvious way to handle 21 classes' worth of
#   variable content, and this project already arrived at the same answer
#   independently.
#
# --- Two entries decoded in structural depth (full page dumps read via a
# subagent, since the raw HTML exceeded single-call context):
#
#   **Druid Class Pack | Classic+ (Hysteric0702, db.ascension.gg)** - NOTE:
#   tagged "Classic+", a different Ascension ruleset than Conquest of
#   Azeroth, so treat as generic-Ascension-technique evidence, not a CoA-
#   specific precedent. A `group` parent with 6 children: `Textures`,
#   `[Druid] Rotation`, `[Druid] Dots`, `[Druid] Reminders`, `[Druid] Buffs`,
#   `[Druid] Defensives` (only the first three were reached before the fetch
#   truncated - Reminders/Buffs/Defensives are referenced by name only).
#   Findings:
#   - **Naming convention**: consistent `[ClassName] Category` bracket
#     prefix per section - directly adoptable, same spirit as Fojji's
#     "DON'T MOVE - ..." convention already noted above.
#   - **A "Dots" category, distinct from Rotation** - a real precedent for
#     giving damage-over-time tracking its own visual lane rather than
#     folding it into Rotation, worth weighing against HUD_DESIGN.md's five
#     tiers if a DoT-heavy custom class needs it.
#   - **Custom spell IDs, 7 digits (1148517, 2304572, 1109875, ...) -
#     confirms Ascension remaps abilities onto its own spell ID space**
#     distinct from stock WotLK's 4-6 digit range. One trigger's
#     `realSpellName` field says "Earthquake" while tracking a Druid spell
#     ID - either a copy-paste artifact or evidence the custom spell
#     database reuses/relabels IDs across classes. Relevant caution for any
#     future spell-ID lookup work: don't assume a spell ID's name field is
#     trustworthy without cross-checking.
#   - **A `customTriggerLogic` Lua snippet checking `GetSpellInfo()` on two
#     hard-coded IDs to detect a "Storm" vs "Primal" spell-rank variant** -
#     a real, working pattern for handling Ascension's custom talent/rank
#     system inside a single aura, worth reusing if this project ever needs
#     rank-variant detection.
#   - **A hand-written `dynamicgroup` `customGrow` Lua function** that
#     computes icon positions under a bar whose width changes at runtime
#     (`aura_env.maxWidth = 300`, divided by icon count) - reaches directly
#     into `WeakAuras.regionTypes[...].modify()` internals. More advanced/
#     fragile than anything this project has built so far; flag as a
#     "possible, but hacky" pattern rather than a template to copy uncritically.
#   - Icons uniformly carry subbackground/subborder/subglow/subtext - matches
#     this project's own icon-dressing approach (Glow + Border sub-regions),
#     independent confirmation it's the standard combination.
#   - Anchors to `ElvUF_Player` (an ElvUI unit-frame anchor) - a reminder
#     that a lot of real packs assume a specific unit-frame addon is
#     installed; this project's HUD deliberately keeps HP off its own tiers
#     for the same underlying reason (USE_CASE.md's HP decision).
#
#   **All Stat Tracker (notifikasi, db.ascension.gg)** - a `dynamicgroup` of
#   flat, non-bracketed `text`-only auras (Ranged/Melee AP, Crit, ArPen,
#   Spell Power, Spell Crit, Spell Haste - no bars or icons at all). The
#   author's own note: "not my Original Build, i just take from some
#   Website and put them together" - individual auras credit "Patchett#11593"
#   as original creator, confirming this is a ported stock-Classic
#   community stat-tracker, not Ascension-native content, despite living in
#   the Ascension database. Useful as a reminder that not everything hosted
#   on a server-specific database is actually server-specific - check the
#   author's own notes before treating a find as evidence of local
#   convention. Mechanically: every child polls WoW API stat functions
#   (`UnitDamage`, `UnitRangedAttackPower`, etc.) via a `custom`/`status`
#   trigger throttled to 1/sec (a `GetTime()` delta check in
#   `customTriggerLogic` - a real, reusable perf pattern for any
#   frequently-recalculated custom trigger this project builds later).
#
# --- General (non-Ascension-specific) community conventions, searched per
# Battlewrath's requested categories:
#
#   **Imp/pet management** - modern retail Wild Imp/Dread Stalker trackers
#   (Warlock Demonology) are architecturally identical to what USE_CASE.md
#   already found and documented for this project's own Necromancer/Tinker
#   research: a per-summon progress bar showing time-since-summon (not a
#   real HP query), because the underlying API limitation (no unit token
#   for extra simultaneous summons) is the same on every version. Nothing
#   new here beyond what's already in USE_CASE.md's "Tracking
#   non-directly-controlled pets" section - this independently corroborates
#   that section's conclusion rather than adding a new technique.
#
#   **Target/enemy cast bar tracking** - community packs commonly build this
#   as its own dedicated module/dynamic-group (e.g. "M+ Enemy Targeted
#   Casts DG" tracks dangerous casts across multiple simultaneous enemies
#   via nameplates rather than one single-target cast bar), consistent with
#   HUD_DESIGN.md's own conclusion that this is inherently variable-count
#   and belongs in a separate DynamicGroup module, not a fixed HUD slot.
#
#   **Resource management** - standard community convention is one bar/counter
#   per resource type (mana/rage/energy/focus/runic power/soul shards/holy
#   power/combo points/chi), built via the Power status trigger with `%p`
#   text overlays - exactly the `aurabar`/dynamic-text mechanism already
#   inventoried in CAPABILITY_INVENTORY.md, no new capability surfaced.
#
#   **Rotation helpers** - the community distinguishes "rotation helper"
#   (WeakAuras-based, hand-authored priority icons - typically a "use now" /
#   "use next" pair of icons) from dedicated priority-helper addons like
#   Hekili, which some WeakAuras rotation packs explicitly port logic from.
#   Confirms this project's Rotation tier (steady, resource/priority-driven,
#   not urgency-driven) matches the standard community framing rather than
#   being a novel invention.
#
#   **Broad survey** - no category turned up outside this project's existing
#   four opportunity types (cooldown_tracker, proc_alert, buff_uptime,
#   stack_counter) or five HUD tiers, beyond what earlier research already
#   flagged (consumable/prep tracking, utility automation - see section 3
#   above). The "Conquest of Azeroth" catalog's Attunements/Essences/
#   Runes/Cosmic/Primordial entries are the one genuine new category: a
#   meta-progression/endgame-currency tracking use case, distinct from
#   combat-state tracking entirely - noted for completeness, not a fit for
#   HUD_DESIGN.md's combat-focused five tiers.
#
# --- Not found / inconclusive:
#   - `forum.ascension.gg/tags/weakauras` - CHECKED VIA CHROME (2026-07-06),
#     resolved rather than left inconclusive: both `forum.ascension.gg` and
#     `forums.ascension.gg` return real browser error pages (not a JS-shell
#     issue like db.ascension.gg - genuinely no site there). ascension.gg's
#     own top-nav "Community" menu confirms this: it only lists Discord,
#     Leaderboards, and Watch - no Forums entry at all. Google's own AI
#     overview for "ascension forum weakauras" independently states WeakAuras
#     are found "primarily on the Ascension Database or community sharing
#     hubs like Wago.io, rather than the official forums." Conclusion: the
#     official forum is gone/deprecated, not merely hard to browse - Discord
#     is the real community hub now. This means `DISCORD_POST.md` (this
#     project's community-documentation draft) is already targeting the
#     correct, and only, live venue - not a fallback.
#   - Same search surfaced real third-party video content worth knowing
#     about even though it's not this project's own research: "Beginner's
#     Guide to WeakAuras in Project Ascension" (Project Ascension Hub,
#     2025-04-13) and at least two videos by "MN Phantom" ("Weak Auras
#     Tutorial! Project Ascension," "Advanced Weak Aura Guide Project
#     Ascension | Bronzebeard...") - general Ascension WeakAuras tutorials,
#     not confirmed CoA-ruleset-specific. Not reviewed in depth this pass.
#   - No Ascension-specific rotation-helper or target-cast-bar aura turned
#     up by name in this pass - the 14-entry CoA catalog above is
#     comprehensive for db.ascension.gg's "Conquest of Azeroth" tag
#     specifically, but rotation-helper/cast-bar content may simply be
#     tagged under a different category or not yet built for this ruleset.

# ============================================================================
# 10. "Pitho - Tinker" (2026-07-06) - POISONED reference, concepts only
# ============================================================================
#
# PROVENANCE - read this before touching anything below. Unlike Fojji/
# Luxthos above (public wago.io listings, attributed, license-clear),
# this one was pasted directly into chat by Battlewrath - a real WeakAuras
# import string someone shared in the project's Discord after mentioning
# they'd "re-engineer their addon." No public listing URL, no confirmed
# license, author identity is only a guess from the pack's own top-level
# id ("Pitho - Tinker"). Decoded via this project's own weakaura_codec.py
# (`decode_group_import_string`) - first real confirmation that decoder
# correctly handles a genuinely NESTED group export (envelope version
# 2000, real parent chains, group-inside-group), which the encoder side
# of this same module explicitly doesn't support building yet.
#
# TREAT AS POISONED: mine this for CONCEPTS ONLY. Never copy a field
# value, a spellID, a size, a color, or any structural fragment out of
# `reference_captures/pitho_tinker_decoded.json` directly into anything
# we actually ship - unknown provenance, unknown quality control, unknown
# license. Anything we decide is worth using gets rebuilt from scratch to
# this project's own conventions (see AURA_BLUEPRINT.md/HUD_DESIGN.md),
# the same way Fojji/Luxthos above were treated as inspiration, just with
# a harder line here given the murkier sourcing.
#
# Raw materials kept alongside this file (not embedded here - 93 auras,
# too large for a readable Python literal):
#   - Weak Auras/reference_captures/pitho_tinker_import.txt   (raw !WA:2! string)
#   - Weak Auras/reference_captures/pitho_tinker_decoded.json (full decode,
#     group + all 93 children, via weakaura_codec.decode_group_import_string)
#
# WHAT'S ACTUALLY USEFUL (concepts, verified by reading the real decode,
# not assumed):
#
# - **`dynamicgroup` as a "pack tight, no gaps" container for a FIXED
#   roster**, not a Custom-trigger-driven variable pool. Every child
#   under "Tinker - Abilities"/"Tinker - CDs"/"Tinker - UPTIME" is an
#   ordinary aura with its OWN spellknown-gated load condition and its
#   own "Cooldown Progress (Spell)" trigger; the dynamicgroup's only job
#   is auto-arranging whichever ones are currently passing. Different
#   (simpler) mechanism than the "one Custom Group trigger emitting
#   per-slot keys" approach discussed for totem tracking - good fit for
#   "all of a class's fixed ability list," not for a genuinely variable
#   0-4 pool like active totem slots.
# - **Combat-log-based tracking for a persistent player-summoned object
#   that ISN'T a real totem** - the "Beacons" (Restorative/Shield/
#   Replenishment) are `aurabar`s keyed on a `combatlog` trigger, gated by
#   spellknown/talentknown, not on any totem-frame/GetTotemInfo mechanism.
#   Concrete fallback pattern for any future ability that summons
#   something but doesn't register as a real totem slot.
# - **Cooldown-ready via desaturation, not glow**: the standard leaf
#   pattern here is a "Cooldown Progress (Spell)" trigger, always shown,
#   with exactly one condition (`onCooldown==1` -> `desaturate=true`) -
#   a simpler, valid alternative to this project's own glow-based
#   ready-check convention.
# - **Swing timer built from stock triggers**: `unit`/"Swing Timer" +
#   a secondary `unit`/"Conditions" trigger, three parallel `aurabar`s
#   (Main/Off-hand/Ranged) - confirms CAPABILITY_INVENTORY.md's native
#   Swing Timer finding with a second real, working example.
# - **"NOT IN USE ATM" parked-subgroup naming** - a whole subgroup
#   ("Tinker - Glows NOT IN USE ATM") left in place but flagged retired
#   rather than deleted. Same spirit as this project's own `Outputs/
#   Archive/` convention; trivially adoptable as a labeling habit.
#
# ONE HYGIENE HAZARD FLAGGED, not fixed anywhere, just worth knowing:
# several children carry stale multi-class load-condition leftovers -
# e.g. "Tinker - Castbar"'s `class.multi` still lists Mage/Monk/Priest/
# Warrior/etc. even though `single = "TINKER"` (+ `use_class`) is what's
# actually active. Reads like debris from cloning another class's aura as
# a starting template rather than a real functional bug, but a concrete
# reminder that a decoded `load.multi` dict can be leftover UI state, not
# necessarily live logic - check `single`/`use_*` first.
PITHO_TINKER_SECTION_TAXONOMY = [
    "Tinker - Beacons",       # group   - Restorative/Shield/Replenishment Beacon bars
    "Tinker - Greater Bionics",  # icon (top-level, not in a subfolder)
    "Tinker - Resources",     # group   - Castbar, nested SwingTimers group,
                              #           nested Rocket Jump dynamicgroup, Manabar, Scrap
    "Tinker - Glows NOT IN USE ATM",  # group   - parked/retired, kept not deleted
    "Tinker - Abilities",     # dynamicgroup - ~14 fixed cooldown icons
    "Tinker - CDs",           # dynamicgroup - ~24 fixed major-CD icons
    "Tinker - UPTIME",        # dynamicgroup - ~23 buff/proc uptime icons
    "Tinker - Procs WIP",     # dynamicgroup - work-in-progress proc icons
]
