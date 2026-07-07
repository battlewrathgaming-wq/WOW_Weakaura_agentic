"""
Necromancer/inventory.py - this class's own slot data, per layer, for
layer_builder.py to consume. Plain constants only (coordinates, options,
spell IDs) - no fill/encode logic here; that's layer_builder.py's job,
shared across every class and layer. See ../layer_builder.py's own
docstring for the full architecture rationale (settled with Battlewrath,
2026-07-06).

Layer numbering here tracks BUILD ORDER, not each layer's in-game tier
number - "Resources" (+ the still-live Template_shadow.py placeholder
scaffolding it superseded) is layer 1; "Tier 1 Rotation" is layer 2, even
though it corresponds to HUD_DESIGN.md's own "Rotation" tier - the two
numbering schemes are allowed to diverge.
"""

import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_THIS_DIR, "..", "Tiers"))
import resources_base as rb

ACCENT_COLOR = [0.2706, 0.8588, 0.6118, 1.0]  # theme.json's accent_rgba

# Necromancer's confirmed power types (slot_assignment.md) - Mana=0, Runic Power=6.
POWERTYPE_MANA = 0
POWERTYPE_RUNIC_POWER = 6

# Runic Power's own real recolor (cyan, #21E8FF) - the one override needed on
# top of Tiers/resources_base.py's shared builders; every other Resources
# child (Mana, Cast Bar, Swing Timer, both backing plates, the divider)
# already matches its shared template's own default fields exactly - see
# resources_base.py's own docstring for the confirmed decode-vs-default
# comparison this relies on.
RUNIC_POWER_BAR_COLOR = [0.12941176470588234, 0.9098039215686274, 1, 1]

LAYERS = {
    # ------------------------------------------------------------------
    # Layer 1: Resources - BACKFILLED 2026-07-09 into Tiers/resources_base.py's
    # shared building blocks, replacing the TODO placeholder that stood here
    # since this file's own creation. Built through 13 iterative ad-hoc
    # sessions before inventory.py existed (Resources_v1 through v13), then
    # a 14th real revision this same session (the center-seam divider-strip
    # geometry fix, see slot_assignment.md's own writeup) - this layer
    # definition is a RE-DERIVATION of that already-live v14 capture via the
    # shared base, not a redesign. Verified byte-for-byte against
    # Resources_v14_import.txt before this backfill was considered done -
    # see slot_assignment.md's own note on that verification.
    #
    # Two-class motivation for finally doing this backfill now (not before):
    # Reaper's own Resources tier (Soul Fragment + Runic Power) needs the
    # EXACT same Runic Power/Cast Bar/Swing Timer/divider mechanism -
    # building that from scratch a second time would have been real,
    # immediate duplication, not a hypothetical future one. Per Battlewrath:
    # "it's more centered on the mask / backing plates and positional
    # indexes as a source of truth per slot. Then a class defines with it's
    # own inventory how they're populated."
    # ------------------------------------------------------------------
    "Resources": {
        "region_type": "group",
        "slots": [
            rb.resource_slot("Mana", rb.POWERTYPE_MANA, rb.CLASS_RESOURCE_POS),
            rb.resource_slot("Runic Power", rb.POWERTYPE_RUNIC_POWER, rb.CLASS_ENERGY_POS, bar_color=RUNIC_POWER_BAR_COLOR),
            rb.cast_bar_backing_slot(),
            rb.cast_bar_slot(),
            rb.swing_timer_backing_slot(),
            rb.swing_timer_slot(),
            rb.divider_strip_slot(),
        ],
    },

    # ------------------------------------------------------------------
    # Layer 2: Tier 1 Rotation. Positions from the settled mask
    # (Template_shadow_v0.14_import.txt's "Tier 1 slot Rotation"/"slot 2"/
    # "slot 3" - six slots exist total).
    #
    # PARED DOWN 2026-07-06 (later same day) to just Command: Undead, per
    # Battlewrath's explicit call to stop over-committing: "getting the
    # more up to date rotation bar up to date. Paired down to just the
    # command:undead... proving the UI rather than trying to build it all
    # outright." Context: Battlewrath is level 10 on a server that's been
    # up one day - most of the abilities this project had been scoping
    # (Crypt Swarm, the wider 23-ability class audit) aren't even reachable
    # yet, and the honest priority right now is validating the HUD
    # mechanism itself on the one real, in-use ability, not building out
    # the full kit ahead of actually playing it.
    #   - LICHFROST (501969) - stays dropped (see prior revision below -
    #     confirmed pure Runic Power builder via Ice Barrage).
    #   - CRYPT SWARM (500965) - DROPPED this pass too, per Battlewrath:
    #     "Crypt can be dropped also. It is only a channeled runic
    #     builder" - same builder classification as Lichfrost, just
    #     channeled instead of a windup cast. (The earlier "press_wash
    #     KEPT, no real cooldown" note below is now superseded by this -
    #     left in place as history, not deleted, since it's still accurate
    #     about why db.ascension.gg's 15s cooldown claim for this spell
    #     was wrong.)
    #   - COMMAND: UNDEAD (504868) - the only slot left. press_wash
    #     REMOVED from this build: it never reliably fired in-game for
    #     this ability even after the sourceUnit/spellName/CAST_SUCCESS
    #     fixes (see template_filler.py's press_wash comment) - shipping a
    #     feature that doesn't visibly work isn't "proving the UI."
    #     NOT deleted from the codebase - press_wash is confirmed
    #     genuinely working live (Lichfrost, real in-game test) and stays
    #     available as a fragment/schema/template_filler mechanism for
    #     whatever ability actually earns it next. Command: Undead keeps
    #     its afford-glow (power_threshold's include_afford_glow) - that
    #     one IS confirmed working and is the "opportunity" signal;
    #     press_wash was only ever the separate "response" signal layered
    #     on top, per Battlewrath's "Glow is opportunity. Wash is
    #     response" - dropping the response layer doesn't touch the
    #     opportunity layer underneath it.
    # ------------------------------------------------------------------
    "Tier 1 Rotation": {
        "region_type": "group",
        "slots": [
            {
                # Slot 2 (-64.5, -130) - vacated by Crypt Swarm (dropped
                # 2026-07-06, see this layer's own header comment above).
                # Added 2026-07-09: SKELETAL ARCHERS (805040), per
                # Battlewrath: "Show when available. Then desaturate whilst
                # on cooldown... see if this can be handled as one WA item,
                # instead of 2 (backplate vs live)." Answer: yes - uses the
                # new desaturate_on_cooldown param (see build_templates.py's
                # COOLDOWN_TRACKER_ICON_SCHEMA and template_filler.py's own
                # handling block) instead of a backing_plate_icon pairing.
                # No power_threshold/press_wash given yet - not requested,
                # and no real cost/no-cooldown-response data confirmed for
                # this ability yet.
                "template": "cooldown_tracker_icon",
                "params": {
                    "name": "Skeletal Archers",
                    "spell_id": 805040,
                    "x": -64.5,
                    "y": -130,
                    "accent_color": ACCENT_COLOR,
                    "desaturate_on_cooldown": True,
                },
            },
            {
                "template": "cooldown_tracker_icon",
                "params": {
                    "name": "Command: Undead",
                    "spell_id": 504868,
                    "x": -21.5,
                    "y": -130,
                    "accent_color": ACCENT_COLOR,
                    "power_threshold": {
                        "powertype": POWERTYPE_RUNIC_POWER,
                        "cost": 30,
                        "cost_is_percent": False,
                        "include_afford_glow": True,
                    },
                    # press_wash intentionally omitted here (2026-07-06) -
                    # see this layer's own header comment above for why.
                },
            },
        ],
    },

    # ------------------------------------------------------------------
    # Layer 3: Necro_animation_spec_UI_element - Battlewrath's own live
    # dev/test group, indexed here 2026-07-08 so it's picked up in future
    # compiler builds/exports rather than only existing as a hand-edited
    # in-game aura. Reconstructed field-for-field from a real pasted
    # export (decoded via weakaura_codec.py) of the group Battlewrath is
    # actively using to prototype where this stuff lives on the mask -
    # positions here are Battlewrath's own current dev/test coordinates,
    # NOT a settled mask position (explicitly confirmed: "Undefined. This
    # will live around the UI for the necro" - a real mask is still being
    # worked out). Revisit x/y once that mask is settled.
    #
    # 3 slots:
    #   1. Life Force delta flash text (stack_delta_flash_text) - the
    #      already-formalized Life Force tracker, re-styled in-game:
    #      font 'MoK' (was 'Friz Quadrata TT'), font_size 13 (was 20),
    #      color recolored to a teal. The font override required adding
    #      a new 'font' param to stack_delta_flash_text this same pass
    #      (previously hardcoded, unreachable) - see build_templates.py's
    #      STACK_DELTA_FLASH_TEXT_SCHEMA for the field's own note.
    #   2. Undead Stance (stance_loader_icon) - same 3-option stance
    #      loader built 2026-07-08, moved into this dev group at
    #      Battlewrath's own chosen test position.
    #   3. Ward active (stance_loader_icon, NEW) - Battlewrath built this
    #      one THEMSELVES, by hand in-game, reusing the exact same
    #      stance_loader_icon mechanism (N name-matched aura2 triggers,
    #      disjunctive:any, activeTriggerMode:-10) for a second real
    #      mutually-exclusive pair: Fetid Ward vs Bone Ward. Bone Ward's
    #      own live trainer tooltip confirms "Only 1 Ward can be active
    #      at a time" (Outputs/live_reference/necromancer_live_reference.
    #      json) - the same mutual-exclusivity shape as the stances,
    #      independently confirmed. Indexed here as a real, compiler-
    #      tracked element (not just a hand-built one-off) per
    #      Battlewrath's explicit request: "I'd index it so it gets
    #      picked up in future builds for export."
    #
    #   BEHAVIOUR FIX, 2026-07-08 (second pass) - Battlewrath's real bug
    #   report on this live build: "This is behaviour; they violate the
    #   owned footprint when not active. And stance uses the same icon on
    #   all 3 it seems." Two fixes, both slot-level, no position change
    #   (explicitly deferred - "Not position yet"):
    #   1. A backing_plate_icon slot added directly behind each
    #      stance_loader_icon (same x/y, listed first so it renders
    #      underneath - see backing_plate_icon.schema.json) so the slot's
    #      footprint stays visible even when no option is currently
    #      active, same fix already proven for Cast Bar/Swing Timer, now
    #      generalized to icons for the first time.
    #   2. Undead Stance's stance_loader_icon now carries border_colors
    #      (grey/white=Pacify=passive, blue=Protect=defensive, blood
    #      red=Assault=aggressive) since iconSource=-1 was resolving to
    #      the same icon art for all 3 options in-game - the border is
    #      the actual distinguishing signal now, not the icon art. Ward
    #      active is NOT given border_colors yet (not reported as
    #      exhibiting the same same-icon issue) - left as a plain
    #      stance_loader_icon, unaffected by this fix.
    # ------------------------------------------------------------------
    "Necro_animation_spec_UI_element": {
        "region_type": "group",
        "slots": [
            {
                "template": "stack_delta_flash_text",
                "params": {
                    "name": "LF Delta Test",
                    "spell_id": 525004,
                    "aura_filter": "HARMFUL",
                    "x": 173.80164568420787,
                    "y": -109.3362841971246,
                    "label_suffix": " LF",
                    "font": "MoK",
                    "font_size": 13,
                    "color": [0.0, 0.6745098039215687, 0.5450980392156862, 1.0],
                    # load_conditions added 2026-07-08, per Battlewrath's real
                    # hand-built edit on this exact instance (pasted back and
                    # decoded via weakaura_codec.py): "Must be on necromancer"
                    # + "In Combat". Battlewrath's own framing: "I imagine the
                    # whole pack will use the 'Must be on necromancer'. The
                    # in-combat will be more selective. Such as the proc
                    # tier... this is a new class of action that a WA can
                    # adhere to." See build_templates.py's
                    # LOAD_CONDITIONS_SCHEMA for the full mechanism writeup
                    # and the broader load_prototype field catalog. Only this
                    # one real slot has been retrofitted so far - a blanket
                    # classes=["NECROMANCER"] pass across the rest of the pack
                    # is a natural next step Battlewrath anticipated but has
                    # NOT been applied yet (deliberately, per this project's
                    # build-one-confirmed-instance-before-generalizing rule).
                    "load_conditions": {"classes": ["NECROMANCER"], "combat": True},
                },
            },
            {
                "template": "backing_plate_icon",
                "params": {
                    "name": "Undead Stance Backing",
                    "x": 268.3431767418281,
                    "y": -109.29426707719983,
                    # REVISED 2026-07-08 (fourth pass) - Battlewrath hand-built
                    # a better fix in-game and pasted it back (decoded via
                    # weakaura_codec.py): no spell ID needed at all. A second
                    # aura2 trigger (matchesShowOn: showOnMissing) on the SAME
                    # 3 option names as the paired stance_loader_icon lets
                    # WeakAuras resolve an icon for the named spell(s) live,
                    # by name, even with no spellId captured in our own data.
                    # Own words: "It is basically an anti statement. If
                    # neither of those auras are present, then show the
                    # desaturated version." See backing_plate_icon.schema.
                    # json's "missing_state_option_names" note for the full
                    # mechanism. color matches Battlewrath's own real recolor
                    # (a muted grey, better suited to a real icon showing
                    # through than the original blank-plate default).
                    "color": [0.3568627450980392, 0.3568627450980392, 0.3568627450980392, 0.72],
                    "missing_state_option_names": ["Undead: Pacify", "Undead: Protect", "Undead: Assault"],
                },
            },
            {
                "template": "stance_loader_icon",
                "params": {
                    "name": "Undead Stance",
                    "option_names": ["Undead: Pacify", "Undead: Protect", "Undead: Assault"],
                    "x": 268.3431767418281,
                    "y": -109.29426707719983,
                    # grey/white=passive, blue=defensive, blood red=aggressive
                    # (Battlewrath, 2026-07-08) - exact hex tunable later,
                    # this is a first pass, low-risk per project convention.
                    "border_colors": [
                        [0.85, 0.85, 0.85, 1.0],
                        [0.1, 0.3, 0.7, 1.0],
                        [0.55, 0.05, 0.05, 1.0],
                    ],
                },
            },
            {
                "template": "backing_plate_icon",
                "params": {
                    "name": "Ward active Backing",
                    "x": 309.12751436798817,
                    "y": -109.76470754778336,
                    # fallback_icon added 2026-07-08 (third pass), per
                    # Battlewrath's live-test report on the plain blank-plate
                    # version: "The backing plate did fail however. As it has
                    # no icon." Fetid Ward has a real, confirmed spellId
                    # (680388, source: "talent") in
                    # Outputs/live_reference/necromancer_live_reference.json -
                    # shown here desaturated, no border, per Battlewrath's own
                    # proposed fix (see backing_plate_icon.schema.json).
                    "fallback_icon": 680388,
                },
            },
            {
                "template": "stance_loader_icon",
                "params": {
                    "name": "Ward active",
                    "option_names": ["Fetid Ward", "Bone Ward"],
                    "x": 309.12751436798817,
                    "y": -109.76470754778336,
                },
            },
        ],
    },

    # ------------------------------------------------------------------
    # Layer 4: Minion tracker - a dynamicgroup, added 2026-07-09, formalizing
    # Battlewrath's own real, hand-built "Minion tracker" DynamicGroup
    # (decoded via weakaura_codec.py - see build_templates.py's
    # MINION_PRESENCE_ICON_SCHEMA for the full research/build trail).
    # Battlewrath's explicit instruction for this pass: "Let's build around
    # the expected, normal function. Then add the tailored items later" -
    # i.e. match the real capture's plain useStacks/%s behavior exactly,
    # deliberately NOT yet fixing the known matchCount/bestMatch accuracy
    # limitation (each minion of a type applies its own separate, non-
    # stacking guardian-count aura, so "%s" shows presence-of-one, not a
    # true aggregate count - see that schema's "verified" field).
    #
    # group_layout matches the real capture's own group-level fields
    # field-for-field (decoded 2026-07-08/09): grow RIGHT, align CENTER,
    # sort none, space 2, selfPoint LEFT, and the real x/yOffset Battlewrath's
    # own placement landed on.
    #
    # 3 slots, one per confirmed guardian-count owner-buff spell ID
    # (Necromancer/spell_index.md's "Guardian count buff" section,
    # confirmed live 2026-07-06/07 for Skeletal Warrior/Abomination;
    # Crypt Keeper's real ID corrected by Battlewrath, 2026-07-09, from an
    # earlier five-digit guess of 80035): Abomination 805017, Crypt Keeper
    # 800034 (displayed as "Crypt Fiend" in Battlewrath's own real capture -
    # kept as this slot's display name), Skeleton 805016. guardian_aura_id
    # is passed as a clean int (not the real capture's raw
    # "800034 "-with-trailing-space string) since fill_template's {{}}
    # substitution stringifies whatever is given - passing a clean int
    # avoids reproducing that harmless-but-needless artifact.
    #
    # OPEN QUESTION, not yet resolved (see build_templates.py's own note):
    # the real capture's screenshot showed 4 icons + a "0/4" readout, but
    # only 3 children actually decode from the transmitted data - likely
    # WeakAuras' own options-window/editor UI chrome, not real exported
    # aura data, but not independently confirmed.
    # ------------------------------------------------------------------
    "Minion tracker": {
        "region_type": "dynamicgroup",
        "group_layout": {
            "grow": "RIGHT",
            "align": "CENTER",
            "sort": "none",
            "space": 2,
            "selfPoint": "LEFT",
            "xOffset": 266.0388878566216,
            "yOffset": -183.21538882488227,
        },
        "slots": [
            {
                "template": "minion_presence_icon",
                "params": {"name": "Abomination", "guardian_aura_id": 805017, "x": 0, "y": 0},
            },
            {
                "template": "minion_presence_icon",
                "params": {"name": "Crypt Fiend", "guardian_aura_id": 800034, "x": 0, "y": 0},
            },
            {
                "template": "minion_presence_icon",
                "params": {"name": "Skeleton", "guardian_aura_id": 805016, "x": 0, "y": 0},
            },
        ],
    },

    # ------------------------------------------------------------------
    # Layer 5: Buff Index - the first real content in HUD_DESIGN.md's
    # "Buffs/Utility" tier, added 2026-07-09. Battlewrath's own framing:
    # "These can be our 2 anchors for the buff section / index... We'll
    # leave the dynamic group for when I unlock more buffs" - a static
    # `group` layer for now (NOT dynamicgroup, unlike Minion tracker),
    # occupying ELEMENT_INVENTORY.md's Row E's own pre-settled 2 static
    # Buffs slots ("Tier 3 Buffs 2"/"Tier 3 Buffs 3", -172.5/-142.5, y
    # -185, 30x20 icon) - the dynamic-overflow rows below (Row F,
    # "Tier 3 Buffs 4-7 dynamic") stay reserved, unbuilt, for exactly the
    # future expansion Battlewrath is deferring here.
    #
    # 2 real buffs, each built as a PAIR of slots at the same x/y (backing
    # first, so it renders underneath - same ordering convention as the
    # stance-loader backing plates): a `backing_plate_icon` with
    # `fallback_icon` (always shown, desaturated, no border - the "not
    # present" state) plus a `buff_uptime_icon` on top (aura2, ownOnly,
    # ONLY shows - full color, no desaturation - while the buff is
    # actually present). This is not a new mechanism - it's the exact
    # backing+real-icon pairing already proven for "Ward active Backing"/
    # "Ward active" above, just applied to a plain single buff instead of
    # an N-way mutually-exclusive stance set. No dynamicgroup, no new
    # template, no schema change needed for this pass.
    #
    #   - RAZORICE (500967)
    #   - FOUL MANDATE (800199)
    #
    # Neither spell had any prior indexed data in Necromancer/spell_index.md
    # or Outputs/live_reference/ - taken directly from Battlewrath's own
    # given IDs, same as Crypt Keeper's ID correction earlier. Not yet
    # cross-checked against a live source; flag if either ID turns out
    # wrong the same way Crypt Keeper's five-digit guess did.
    # ------------------------------------------------------------------
    "Buff Index": {
        "region_type": "group",
        "slots": [
            {
                "template": "backing_plate_icon",
                "params": {
                    "name": "Razorice Backing",
                    "x": -172.5,
                    "y": -185,
                    "fallback_icon": 500967,
                },
            },
            {
                "template": "buff_uptime_icon",
                "params": {
                    "name": "Razorice",
                    "spell_id": 500967,
                    "x": -172.5,
                    "y": -185,
                },
            },
            {
                "template": "backing_plate_icon",
                "params": {
                    "name": "Foul Mandate Backing",
                    "x": -142.5,
                    "y": -185,
                    "fallback_icon": 800199,
                },
            },
            {
                "template": "buff_uptime_icon",
                "params": {
                    "name": "Foul Mandate",
                    "spell_id": 800199,
                    "x": -142.5,
                    "y": -185,
                },
            },
        ],
    },
}
