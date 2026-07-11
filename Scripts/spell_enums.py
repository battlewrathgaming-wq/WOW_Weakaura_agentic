"""
spell_enums.py - SOURCED value-domain grounding for the Spell.dbc Effect + EffectApplyAura
fields. These are DEFINED FACTS (not guessable): the standard WotLK 3.3.5a enums, kept here
VERBATIM from their authorities so the grounding is self-documenting and re-parseable.

Sources (read-the-authority, per the project discipline):
  - SpellEffect 0..164  -> TrinityCore/WowPacketParser Enums/SpellEffect.cs (TOTAL_SPELL_EFFECTS=165)
  - AuraType   0..316   -> TrinityCore SpellAuraDefines.h  enum AuraType     (TOTAL_AURAS=317)

CUSTOM-detection: 3.3.5a stops at effect 164 / aura 316. Ascension (COA) added its own
beyond that range -> any value > the max is Ascension-CUSTOM, unsourceable from stock
headers, and becomes a route-6 rim (resolve by behaviour / dev, not by this table).

    from spell_enums import EFFECT, AURA, effect_name, aura_name, is_custom_effect, is_custom_aura
"""

EFFECT_MAX = 164   # 3.3.5a TOTAL_SPELL_EFFECTS-1; > this = Ascension-custom
AURA_MAX = 316     # 3.3.5a TOTAL_AURAS-1;          > this = Ascension-custom

# --- verbatim from WowPacketParser Enums/SpellEffect.cs (0..164) ---
_EFFECT_SRC = """
0=none 1=instakill 2=school_damage 3=dummy 4=portal_teleport 5=teleport_units 6=apply_aura
7=environmental_damage 8=power_drain 9=health_leech 10=heal 11=bind 12=portal 13=ritual_base
14=ritual_specialize 15=ritual_activate_portal 16=quest_complete 17=weapon_damage_noschool
18=resurrect 19=add_extra_attacks 20=dodge 21=evade 22=parry 23=block 24=create_item 25=weapon
26=defense 27=persistent_area_aura 28=summon 29=leap 30=energize 31=weapon_percent_damage
32=trigger_missile 33=open_lock 34=summon_change_item 35=apply_area_aura_party 36=learn_spell
37=spell_defense 38=dispel 39=language 40=dual_wield 41=jump 42=jump_dest
43=teleport_units_face_caster 44=skill_step 45=add_honor 46=spawn 47=trade_skill 48=stealth
49=detect 50=trans_door 51=force_critical_hit 52=guarantee_hit 53=enchant_item
54=enchant_item_temporary 55=tamecreature 56=summon_pet 57=learn_pet_spell 58=weapon_damage
59=create_random_item 60=proficiency 61=send_event 62=power_burn 63=threat 64=trigger_spell
65=apply_area_aura_raid 66=create_mana_gem 67=heal_max_health 68=interrupt_cast 69=distract
70=pull 71=pickpocket 72=add_farsight 73=untrain_talents 74=apply_glyph 75=heal_mechanical
76=summon_object_wild 77=script_effect 78=attack 79=sanctuary 80=add_combo_points 81=create_house
82=bind_sight 83=duel 84=stuck 85=summon_player 86=activate_object 87=gameobject_damage
88=gameobject_repair 89=gameobject_set_destruction_state 90=kill_credit 91=threat_all
92=enchant_held_item 93=force_deselect 94=self_resurrect 95=skinning 96=charge 97=cast_button
98=knock_back 99=disenchant 100=inebriate 101=feed_pet 102=dismiss_pet 103=reputation
104=summon_object_slot1 105=summon_object_slot2 106=summon_object_slot3 107=summon_object_slot4
108=dispel_mechanic 109=summon_dead_pet 110=destroy_all_totems 111=durability_damage 112=unk112
113=resurrect_new 114=attack_me 115=durability_damage_pct 116=skin_player_corpse 117=spirit_heal
118=skill 119=apply_area_aura_pet 120=teleport_graveyard 121=normalized_weapon_dmg 122=unk122
123=send_taxi 124=pull_towards 125=modify_threat_percent 126=steal_beneficial_buff 127=prospecting
128=apply_area_aura_friend 129=apply_area_aura_enemy 130=redirect_threat 131=unk131 132=play_music
133=unlearn_specialization 134=kill_credit2 135=call_pet 136=heal_pct 137=energize_pct 138=leap_back
139=clear_quest 140=force_cast 141=force_cast_with_value 142=trigger_spell_with_value
143=apply_area_aura_owner 144=knock_back_dest 145=pull_towards_dest 146=activate_rune 147=quest_fail
148=trigger_missile_spell_with_value 149=charge_dest 150=quest_start 151=trigger_spell_2
152=summon_raf_friend 153=create_tamed_pet 154=discover_taxi 155=titan_grip 156=enchant_item_prismatic
157=create_item_2 158=milling 159=allow_rename_pet 160=unk160 161=talent_spec_count
162=talent_spec_select 163=unk163 164=remove_aura
"""

# --- verbatim from TrinityCore SpellAuraDefines.h enum AuraType (0..316), SPELL_AURA_ stripped ---
_AURA_SRC = """
0=none 1=bind_sight 2=mod_possess 3=periodic_damage 4=dummy 5=mod_confuse 6=mod_charm 7=mod_fear
8=periodic_heal 9=mod_attackspeed 10=mod_threat 11=mod_taunt 12=mod_stun 13=mod_damage_done
14=mod_damage_taken 15=damage_shield 16=mod_stealth 17=mod_stealth_detect 18=mod_invisibility
19=mod_invisibility_detect 20=obs_mod_health 21=obs_mod_power 22=mod_resistance
23=periodic_trigger_spell 24=periodic_energize 25=mod_pacify 26=mod_root 27=mod_silence
28=reflect_spells 29=mod_stat 30=mod_skill 31=mod_increase_speed 32=mod_increase_mounted_speed
33=mod_decrease_speed 34=mod_increase_health 35=mod_increase_energy 36=mod_shapeshift
37=effect_immunity 38=state_immunity 39=school_immunity 40=damage_immunity 41=dispel_immunity
42=proc_trigger_spell 43=proc_trigger_damage 44=track_creatures 45=track_resources 46=aura_46
47=mod_parry_percent 48=periodic_trigger_spell_from_client 49=mod_dodge_percent
50=mod_critical_healing_amount 51=mod_block_percent 52=mod_weapon_crit_percent 53=periodic_leech
54=mod_hit_chance 55=mod_spell_hit_chance 56=transform 57=mod_spell_crit_chance
58=mod_increase_swim_speed 59=mod_damage_done_creature 60=mod_pacify_silence 61=mod_scale
62=periodic_health_funnel 63=aura_63 64=periodic_mana_leech 65=mod_casting_speed_not_stack
66=feign_death 67=mod_disarm 68=mod_stalked 69=school_absorb 70=extra_attacks 71=mod_spell_crit_chance_school
72=mod_power_cost_school_pct 73=mod_power_cost_school 74=reflect_spells_school 75=mod_language
76=far_sight 77=mechanic_immunity 78=mounted 79=mod_damage_percent_done 80=mod_percent_stat
81=split_damage_pct 82=water_breathing 83=mod_base_resistance 84=mod_regen 85=mod_power_regen
86=channel_death_item 87=mod_damage_percent_taken 88=mod_health_regen_percent 89=periodic_damage_percent
90=aura_90 91=mod_detect_range 92=prevents_fleeing 93=mod_unattackable 94=interrupt_regen 95=ghost
96=spell_magnet 97=mana_shield 98=mod_skill_talent 99=mod_attack_power 100=auras_visible
101=mod_resistance_pct 102=mod_melee_attack_power_versus 103=mod_total_threat 104=water_walk
105=feather_fall 106=hover 107=add_flat_modifier 108=add_pct_modifier 109=add_target_trigger
110=mod_power_regen_percent 111=add_caster_hit_trigger 112=override_class_scripts 113=mod_ranged_damage_taken
114=mod_ranged_damage_taken_pct 115=mod_healing 116=mod_regen_during_combat 117=mod_mechanic_resistance
118=mod_healing_pct 119=aura_119 120=untrackable 121=empathy 122=mod_offhand_damage_pct
123=mod_target_resistance 124=mod_ranged_attack_power 125=mod_melee_damage_taken 126=mod_melee_damage_taken_pct
127=ranged_attack_power_attacker_bonus 128=mod_possess_pet 129=mod_speed_always 130=mod_mounted_speed_always
131=mod_ranged_attack_power_versus 132=mod_increase_energy_percent 133=mod_increase_health_percent
134=mod_mana_regen_interrupt 135=mod_healing_done 136=mod_healing_done_percent 137=mod_total_stat_percentage
138=mod_melee_haste 139=force_reaction 140=mod_ranged_haste 141=mod_ranged_ammo_haste 142=mod_base_resistance_pct
143=mod_resistance_exclusive 144=safe_fall 145=mod_pet_talent_points 146=allow_tame_pet_type
147=mechanic_immunity_mask 148=retain_combo_points 149=reduce_pushback 150=mod_shield_blockvalue_pct
151=track_stealthed 152=mod_detected_range 153=split_damage_flat 154=mod_stealth_level 155=mod_water_breathing
156=mod_reputation_gain 157=pet_damage_multi 158=mod_shield_blockvalue 159=no_pvp_credit 160=mod_aoe_avoidance
161=mod_health_regen_in_combat 162=power_burn 163=mod_crit_damage_bonus 164=aura_164
165=melee_attack_power_attacker_bonus 166=mod_attack_power_pct 167=mod_ranged_attack_power_pct
168=mod_damage_done_versus 169=mod_crit_percent_versus 170=detect_amore 171=mod_speed_not_stack
172=mod_mounted_speed_not_stack 173=aura_173 174=mod_spell_damage_of_stat_percent
175=mod_spell_healing_of_stat_percent 176=spirit_of_redemption 177=aoe_charm 178=mod_debuff_resistance
179=mod_attacker_spell_crit_chance 180=mod_flat_spell_damage_versus 181=aura_181
182=mod_resistance_of_stat_percent 183=mod_critical_threat 184=mod_attacker_melee_hit_chance
185=mod_attacker_ranged_hit_chance 186=mod_attacker_spell_hit_chance 187=mod_attacker_melee_crit_chance
188=mod_attacker_ranged_crit_chance 189=mod_rating 190=mod_faction_reputation_gain
191=use_normal_movement_speed 192=mod_melee_ranged_haste 193=melee_slow 194=mod_target_absorb_school
195=mod_target_ability_absorb_school 196=mod_cooldown 197=mod_attacker_spell_and_weapon_crit_chance
198=aura_198 199=mod_increases_spell_pct_to_hit 200=mod_xp_pct 201=fly 202=ignore_combat_result
203=mod_attacker_melee_crit_damage 204=mod_attacker_ranged_crit_damage 205=mod_school_crit_dmg_taken
206=mod_increase_vehicle_flight_speed 207=mod_increase_mounted_flight_speed 208=mod_increase_flight_speed
209=mod_mounted_flight_speed_always 210=mod_vehicle_speed_always 211=mod_flight_speed_not_stack
212=mod_ranged_attack_power_of_stat_percent 213=mod_rage_from_damage_dealt 214=aura_214
215=arena_preparation 216=haste_spells 217=mod_melee_haste_2 218=haste_ranged 219=mod_mana_regen_from_stat
220=mod_rating_from_stat 221=mod_detaunt 222=aura_222 223=raid_proc_from_charge 224=aura_224
225=raid_proc_from_charge_with_value 226=periodic_dummy 227=periodic_trigger_spell_with_value
228=detect_stealth 229=mod_aoe_damage_avoidance 230=aura_230 231=proc_trigger_spell_with_value
232=mechanic_duration_mod 233=change_model_for_all_humanoids 234=mechanic_duration_mod_not_stack
235=mod_dispel_resist 236=control_vehicle 237=mod_spell_damage_of_attack_power
238=mod_spell_healing_of_attack_power 239=mod_scale_2 240=mod_expertise 241=force_move_forward
242=mod_spell_damage_from_healing 243=mod_faction 244=comprehend_language 245=mod_aura_duration_by_dispel
246=mod_aura_duration_by_dispel_not_stack 247=clone_caster 248=mod_combat_result_chance 249=convert_rune
250=mod_increase_health_2 251=mod_enemy_dodge 252=mod_speed_slow_all 253=mod_block_crit_chance
254=mod_disarm_offhand 255=mod_mechanic_damage_taken_percent 256=no_reagent_use
257=mod_target_resist_by_spell_class 258=aura_258 259=mod_hot_pct 260=screen_effect 261=phase
262=ability_ignore_aurastate 263=allow_only_ability 264=aura_264 265=aura_265 266=aura_266
267=mod_immune_aura_apply_school 268=mod_attack_power_of_stat_percent 269=mod_ignore_target_resist
270=mod_ability_ignore_target_resist 271=mod_spell_damage_from_caster 272=ignore_melee_reset 273=x_ray
274=ability_consume_no_ammo 275=mod_ignore_shapeshift 276=mod_damage_done_for_mechanic
277=mod_max_affected_targets 278=mod_disarm_ranged 279=initialize_images 280=mod_armor_penetration_pct
281=mod_honor_gain_pct 282=mod_base_health_pct 283=mod_healing_received 284=linked
285=mod_attack_power_of_armor 286=ability_periodic_crit 287=deflect_spells 288=ignore_hit_direction
289=prevent_durability_loss 290=mod_crit_pct 291=mod_xp_quest_pct 292=open_stable 293=override_spells
294=prevent_regenerate_power 295=aura_295 296=set_vehicle_id 297=block_spell_family 298=strangulate
299=aura_299 300=share_damage_pct 301=school_heal_absorb 302=aura_302 303=mod_damage_done_versus_aurastate
304=mod_fake_inebriate 305=mod_minimum_speed 306=aura_306 307=heal_absorb_test 308=mod_crit_chance_for_caster
309=aura_309 310=mod_creature_aoe_damage_avoidance 311=aura_311 312=aura_312 313=aura_313
314=prevent_resurrection 315=underwater_walking 316=periodic_haste
"""


# --- verbatim from TrinityCore SharedDefines.h enum Targets (EffectImplicitTargetA), TARGET_ stripped ---
_TARGET_SRC = """
1=unit_caster 2=unit_nearby_enemy 3=unit_nearby_ally 4=unit_nearby_party 5=unit_pet
6=unit_target_enemy 7=unit_src_area_entry 8=unit_dest_area_entry 9=dest_home
11=unit_src_area_unk_11 15=unit_src_area_enemy 16=unit_dest_area_enemy 17=dest_db 18=dest_caster
20=unit_caster_area_party 21=unit_target_ally 22=src_caster 23=gameobject_target
24=unit_cone_enemy_24 25=unit_target_any 26=gameobject_item_target 27=unit_master
28=dest_dynobj_enemy 29=dest_dynobj_ally 30=unit_src_area_ally 31=unit_dest_area_ally
32=dest_caster_summon 33=unit_src_area_party 34=unit_dest_area_party 35=unit_target_party
36=dest_caster_unk_36 37=unit_lasttarget_area_party 38=unit_nearby_entry 39=dest_caster_fishing
40=gameobject_nearby_entry 41=dest_caster_front_right 42=dest_caster_back_right
43=dest_caster_back_left 44=dest_caster_front_left 45=unit_target_chainheal_ally
46=dest_nearby_entry 47=dest_caster_front 48=dest_caster_back 49=dest_caster_right
50=dest_caster_left 51=gameobject_src_area 52=gameobject_dest_area 53=dest_target_enemy
54=unit_cone_180_deg_enemy 55=dest_caster_front_leap 56=unit_caster_area_raid 57=unit_target_raid
58=unit_nearby_raid 59=unit_cone_ally 60=unit_cone_entry 61=unit_target_area_raid_class
62=dest_caster_ground 63=dest_target_any 64=dest_target_front 65=dest_target_back
66=dest_target_right 67=dest_target_left 68=dest_target_front_right 69=dest_target_back_right
70=dest_target_back_left 71=dest_target_front_left 72=dest_caster_random 73=dest_caster_radius
74=dest_target_random 75=dest_target_radius 76=dest_channel_target 77=unit_channel_target
78=dest_dest_front 79=dest_dest_back 80=dest_dest_right 81=dest_dest_left 82=dest_dest_front_right
83=dest_dest_back_right 84=dest_dest_back_left 85=dest_dest_front_left 86=dest_dest_random
87=dest_dest 88=dest_dynobj_none 89=dest_traj 90=unit_target_minipet 91=dest_dest_radius
92=unit_summoner 93=corpse_src_area_enemy 94=unit_vehicle 95=unit_target_passenger
104=unit_cone_caster_to_dest_enemy 105=unit_caster_and_passengers 106=dest_nearby_db
107=dest_nearby_entry_2 110=unit_cone_caster_to_dest_entry 115=unit_src_area_furthest_enemy
116=unit_and_dest_last_enemy 118=unit_target_ally_or_raid 119=corpse_src_area_raid
120=unit_caster_and_summons 121=corpse_target_ally 122=unit_area_threat_list 123=unit_area_tap_list
124=unit_target_tap_list 125=dest_caster_ground_2 126=unit_caster_area_enemy_clump
127=dest_caster_enemy_clump_centroid 128=unit_rect_caster_ally 129=unit_rect_caster_enemy
130=unit_rect_caster 131=dest_summoner 132=dest_target_ally 133=unit_line_caster_to_dest_ally
134=unit_line_caster_to_dest_enemy 135=unit_line_caster_to_dest 136=unit_cone_caster_to_dest_ally
138=dest_dest_ground 140=dest_caster_clump_centroid 142=dest_nearby_entry_or_db
148=dest_dest_target_towards_caster 150=unit_own_critter
"""

# lane-relevant SpellAttr flags (verbatim values from TrinityCore SharedDefines.h SpellAttr0/1)
ATTR0_ON_NEXT_SWING_A = 0x00000004   # on next swing (no damage)
ATTR0_IS_ABILITY = 0x00000010        # physical ability (not a "spell")
ATTR0_PASSIVE = 0x00000040           # auto-cast on self by core = passive
ATTR0_HIDDEN = 0x00000080            # do-not-display (spellbook/aura/log) = internal
ATTR0_ON_NEXT_SWING_B = 0x00000400   # on next swing
ATTR0_AURA_IS_DEBUFF = 0x04000000    # forced-negative
ATTR1_IS_CHANNELLED = 0x00000004
ATTR1_IS_SELF_CHANNELLED = 0x00000040
ATTR1_INITIATES_COMBAT = 0x00000200  # offensive on-cast


def _parse(src):
    d = {}
    for tok in src.split():
        k, _, v = tok.partition("=")
        d[int(k)] = v
    return d


EFFECT = _parse(_EFFECT_SRC)
AURA = _parse(_AURA_SRC)
TARGET = _parse(_TARGET_SRC)


def target_name(n):
    return None if not n else TARGET.get(n, f"unk_target_{n}")


def target_category(n):
    """Collapse an implicit-target value to a lane-relevant WHO bucket."""
    if not n:
        return None
    nm = TARGET.get(n)
    if nm is None:
        return "other"
    if "cone" in nm:
        return "cone"
    if "chain" in nm:
        return "chain"
    if any(k in nm for k in ("area", "dynobj", "clump", "rect", "line")):
        if "enemy" in nm:
            return "aoe_enemy"
        if any(k in nm for k in ("ally", "party", "raid")):
            return "aoe_ally"
        return "aoe"
    if "target_enemy" in nm or "nearby_enemy" in nm:
        return "single_enemy"
    if any(k in nm for k in ("target_ally", "target_party", "target_raid",
                             "nearby_ally", "nearby_party", "nearby_raid", "chainheal", "ally_or_raid")):
        return "single_ally"
    if nm.startswith("dest"):
        return "dest"                       # ground-placed
    if "caster" in nm or nm == "src_caster" or nm == "unit_summoner":
        return "self"
    if "pet" in nm or "summon" in nm:
        return "pet"
    return "other"


# --- attribute helpers: attr = the 8-int list [attr0..attr7] from the manifest ---
def _a(attr, i):
    return (attr[i] or 0) if attr and len(attr) > i else 0


def is_passive(attr):
    return bool(_a(attr, 0) & ATTR0_PASSIVE)


def is_hidden(attr):
    return bool(_a(attr, 0) & ATTR0_HIDDEN)


def is_ability(attr):
    return bool(_a(attr, 0) & ATTR0_IS_ABILITY)


def is_on_next_swing(attr):
    return bool(_a(attr, 0) & (ATTR0_ON_NEXT_SWING_A | ATTR0_ON_NEXT_SWING_B))


def aura_is_debuff(attr):
    return bool(_a(attr, 0) & ATTR0_AURA_IS_DEBUFF)


def is_channeled(attr):
    return bool(_a(attr, 1) & (ATTR1_IS_CHANNELLED | ATTR1_IS_SELF_CHANNELLED))


def effect_name(n):
    if n is None:
        return None
    return EFFECT.get(n, f"CUSTOM_effect_{n}" if n > EFFECT_MAX else f"unk_effect_{n}")


def aura_name(n):
    if n is None:
        return None
    return AURA.get(n, f"CUSTOM_aura_{n}" if n > AURA_MAX else f"unk_aura_{n}")


def is_custom_effect(n):
    return n is not None and n > EFFECT_MAX


def is_custom_aura(n):
    return n is not None and n > AURA_MAX


if __name__ == "__main__":
    print(f"EFFECT: {len(EFFECT)} (0..{EFFECT_MAX}) | AURA: {len(AURA)} (0..{AURA_MAX}) | TARGET: {len(TARGET)}")
    assert EFFECT[2] == "school_damage" and EFFECT[28] == "summon"
    assert AURA[42] == "proc_trigger_spell" and AURA[3] == "periodic_damage"
    assert target_category(6) == "single_enemy" and target_category(15) == "aoe_enemy"
    assert target_category(1) == "self" and target_category(24) == "cone"
    assert is_passive([0x40, 0, 0, 0, 0, 0, 0, 0]) and is_channeled([0, 0x04, 0, 0, 0, 0, 0, 0])
    print("spot-checks pass.")
