@tool
extends Spell
class_name DamageSpell

const ACCURACY_BONUS : int = 10;
const BASE_STAT : float = 50;

enum SpellHitType { Physical, Special }

@export_group("Base Damage Spell Parameters")
@export_range(0, 250) var spell_power : float = 50;
@export var spell_attack_type : SpellHitType;
@export var vary_defense_type : bool = false;
@export var spell_defense_type : SpellHitType;
@export var ignore_target_defense : bool = false;
@export var ignore_attack_modifiers : bool = false;
@export var ignore_defense_modifiers : bool = false;
@export var ignore_attack_stage : bool = false;
@export var ignore_defense_stage : bool = false;
@export var fixed_damage : bool = false;
@export_range(0, 9999) var fixed_damage_amt : int = 40;
@export var percent_damage : bool = false;
@export_range(0, 1) var percent_damage_amt : float = 0.5;
@export var negate : bool = false;

@export_group("Multi-Hit Parameters")
@export var vary_hit_count : bool = false;
@export_range(1, 10) var min_number_of_hits : int = 1;
@export_range(1, 10) var max_number_of_hits : int = 1;
@export var hit_count_curve : Curve;

@export_group("Accuracy Parameters")
@export var check_accuracy : bool = true;
@export_range(0, 100) var spell_accuracy : float = 100;
@export var check_accuracy_per_hit : bool = false;
@export_range(0, 100) var spell_accuracy_per_hit : float = 100;

@export_group("Critical Hit Parameters")
@export var can_critical : bool = true;
@export_range(1, 24) var critical_chance : int = 16;


func check_spell_hit(cast : SpellCast, user : EntityController, target : EntityController, amt : float = -1):
	if amt == -1 && !check_accuracy : return true;
	
	var accuracy = user.get_accuracy();
	var evasion = target.get_evasion();
	
	var luck = user.param.entity_luck;
	luck = clamp(luck - 1, 0, 10);
	
	# Should never happen but will otherwise divide by zero
	if evasion == 0 : return false;
	
	var base_check = accuracy / evasion;
	var hit = (spell_accuracy + (ACCURACY_BONUS * luck)) * base_check;
	
	if amt != -1 :
		hit = (amt + (ACCURACY_BONUS * luck)) * base_check;
	
	var accuracy_mods = user.get_accuracy_modifiers();
	
	for mod in accuracy_mods:
		hit *= mod;
		accuracy *= mod;
		
	
	var evasion_mods = target.get_evasion_modifiers();
	
	for mod in evasion_mods:
		hit /= mod;
		evasion *= mod;
	
	var result = (randf() * 100) <= hit;
	
	if !result && cast.hit_results.size() == 0 :
		var hit_result = "";
		var entity_name = "";
		var generic = false;
		var rand = randf();
		
		if evasion > accuracy || rand < 0.5:
			hit_result = tr("T_BATTLE_ACTION_DODGE");
			entity_name = target.param.entity_name;
			generic = target.param.entity_generic;
		else :
			if spell_target == SpellTarget.All ||  spell_target == SpellTarget.AllEnemy || spell_target == SpellTarget.AllExceptSelf || spell_target == SpellTarget.AllParty:
				hit_result = tr("T_BATTLE_ACTION_MISS_PLURAL");
			else:
				hit_result = tr("T_BATTLE_ACTION_MISS");
			entity_name = user.param.entity_name;
			generic = user.param.entity_generic;
		
		var formatted_result = BattleScene.Instance.format_dialogue(hit_result, entity_name, user.current_entity, target.param.entity_name, target.current_entity);
		cast.add_hit_result(formatted_result);
	else : cast.add_hit_result("");
	
	return result;


func calculate_damage(user : EntityController, target : EntityController, cast : SpellCast):
	var num_hits = min_number_of_hits;
	
	if vary_hit_count :
		if min_number_of_hits > max_number_of_hits :
			min_number_of_hits = max_number_of_hits;
		
		var luck = 1;
		# Originally included to prevent negative luck but...
		# we kind of want that, no?
		#if user.param.entity_luck > 1:
		luck = user.param.entity_luck;
		var time = hit_count_curve.sample(randf() * luck);
		num_hits = roundi(lerp(min_number_of_hits, max_number_of_hits, time));
	
	var atk_type = spell_attack_type;
	var def_type = spell_attack_type;
	if vary_defense_type : def_type = spell_defense_type;
	
	var result : Array[int];
	var crit : Array[bool];
	var hit : Array[bool];
	var index : Array[int];
	
	for i in num_hits:
		if i > 0 && spell_target == SpellTarget.RandomEnemyPerHit :
			target = cached_targets[randi_range(0, cached_targets.size() - 1)];
		index.append(cached_targets.find(target));
		
		# I think this may be an unfair roll. 
		# It rolls once for the spell, and then again later for the first hit.
		if check_accuracy_per_hit && !check_spell_hit(cast, user, target, spell_accuracy_per_hit):
			hit.append(false);
			crit.append(false);
			result.append(0);
			continue;
		else : 
			cast.clear_hit_result();
		
		hit.append(true);
		
		# Deals damage using a percentage of the target's current HP
		# Will never defeat an enemy except in very exceptional situations
		if fixed_damage && percent_damage :
			crit.append(false);
			var percent = percent_damage_amt * target.current_hp;
			if negate : 
				if target.can_heal : result.append(-roundi(percent));
				else : result.append(0);
			else : result.append(roundi(percent));
			continue;
		# Deals damage using a percentage of the target's maximum HP
		# Use sparingly or for heals
		elif percent_damage : 
			crit.append(false);
			var percent = percent_damage_amt * target.max_hp;
			if negate : 
				if target.can_heal : result.append(-roundi(percent));
				else : result.append(0);
			else : result.append(roundi(percent));
			continue;
		# Deals direct damage using the fixed damage amount
		elif fixed_damage : 
			crit.append(false);
			if negate : 
				if target.can_heal : result.append(-fixed_damage_amt);
				else : result.append(0);
			else : result.append(fixed_damage_amt);
			continue;
		
		var crit_chance = 1;
		# Originally included to prevent negative luck but...
		# we kind of want that, no?
		#if user.param.entity_luck > 1 :
		crit_chance = user.param.entity_luck;
		# If user crit chance modifier is 0, user cannot crit
		if user.param.entity_crit_chance_modifier == 0 : crit_chance = 0;
		else : crit_chance *= user.param.entity_crit_chance_modifier;
		
		# If target crit resist modifier is 0, target cannot be crit
		if target.param.entity_crit_resist_modifier == 0 : crit_chance = 0;
		else : crit_chance /= target.param.entity_crit_resist_modifier;
		
		var critical = false;
		if critical_chance > 0 && can_critical:
			var chance = randf();
			critical = chance < ((1.0 / critical_chance) * crit_chance);
		crit.append(critical);
		
		var atk_mod = user.get_attack_modifier();
		if atk_type == SpellHitType.Special: atk_mod = user.get_sp_attack_modifier();
		var def_mod = target.get_defense_modifier();
		if def_type == SpellHitType.Special: def_mod = target.get_sp_defense_modifier();
		
		var atk = user.param.entity_atk;
		if atk_type == SpellHitType.Special : atk = user.param.entity_sp_atk;
		var def = target.param.entity_def;
		if def_type == SpellHitType.Special : def = target.param.entity_sp_def;
		
		if ignore_attack_stage : atk_mod = 1;
		if ignore_defense_stage : def_mod = 1;
		
		if critical && atk_mod < 1 : atk_mod = 1;
		if critical && def_mod > 1 : def_mod = 1;
		
		# Revised damage formula that takes into account user's level
		var damage = ((((user.level) as float) / 5.0) + 5.0) * spell_power;
		if !ignore_target_defense :
			damage *= (((float)(atk * atk_mod)) / ((float)(def * def_mod)));
		else : 
			var relative_def = ((BASE_STAT * 2 * (user.level)) / 100) + 5;
			damage *= (((float)(atk * atk_mod)) / ((float)(relative_def * def_mod)));
		
		# Scale damage to a lower number range
		damage /= 10.0;
		
		for flag in spell_flags:
			if target.flag_modifiers.has(flag.flag_name_key):
				damage *= target.flag_modifiers[flag.flag_name_key];
		
		var atk_mods_post = user.get_attack_modifiers();
		if atk_type == SpellHitType.Special: atk_mods_post = user.get_sp_attack_modifiers();
		var def_mods_post = target.get_defense_modifiers();
		if def_type == SpellHitType.Special: def_mods_post = target.get_sp_defense_modifiers();
		
		if !ignore_attack_modifiers:
			for f in atk_mods_post :
				damage *= f;
		if !ignore_defense_modifiers:
			for f in def_mods_post:
				damage /= f;
		
		# One time attack boost if flags overlap affinity
		for flag in user.current_entity.affinity:
			if spell_flags.has(flag):
				print("AFFINITY")
				damage *= 1.5;
				break;
		
		print("Full Damage: " + str(damage))
		damage *= randf_range(0.85, 1.0);
		
		if critical : damage *= 1.5
		
		if negate : 
			if target.can_heal : result.append(-roundi(damage));
			else : result.append(0);
		else : result.append(roundi(damage));
	
	cast.set_damage(result);
	cast.set_hits(hit);
	cast.set_critical(crit);
	cast.target_index_override = index;
