@tool
extends Spell
class_name DamageSpell

const ACCURACY_BONUS : int = 10;
const AFFINITY_BONUS : float = 1.25;
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
@export var use_multihit_attack_type : bool = false;
@export var multihit_attack_type : Array[SpellHitType];
@export var randomize_flag_per_hit : bool = false;
@export var randomized_flags : Array[TFlag];

@export_group("Accuracy Parameters")
@export var check_accuracy : bool = true;
@export_range(0, 100) var spell_accuracy : float = 100;
@export var check_accuracy_per_hit : bool = false;
@export_range(0, 100) var spell_accuracy_per_hit : float = 100;
@export var force_dodge_text : bool = false;
@export var force_miss_text : bool = false;
@export var force_miss_plural_text : bool = false;

@export_group("Critical Hit Parameters")
@export var can_critical : bool = true;
@export_range(1, 32) var critical_chance : int = 16;


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
	
	print("BASE HIT RATE: " + str(hit));
	
	var accuracy_mods = user.get_accuracy_modifiers();
	
	for mod in accuracy_mods:
		hit *= mod;
		accuracy *= mod;
	
	var evasion_mods = target.get_evasion_modifiers();
	
	for mod in evasion_mods:
		if mod == 0 :
			hit = 0; 
			break;
		
		hit /= mod;
		evasion *= mod;
	
	print("MODIFIED HIT RATE: " + str(hit));
	
	var result = (randf() * 100) <= hit;
	
	if !result && cast.hit_results.size() == 0 :
		var hit_result = "";
		var entity_name = "";
		var generic = false;
		var rand = randf();
		
		if ((evasion > accuracy || rand < 0.5) || force_dodge_text) && !force_miss_text:
			hit_result = tr("T_BATTLE_ACTION_DODGE");
			entity_name = target.param.entity_name;
			generic = target.param.entity_generic;
		else :
			if (spell_target == SpellTarget.All ||  spell_target == SpellTarget.AllEnemy || spell_target == SpellTarget.AllExceptSelf || spell_target == SpellTarget.AllParty) || force_miss_plural_text:
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
	
	var result : Array[int];
	var crit : Array[bool];
	var hit : Array[bool];
	var index : Array[int];
	var power : float = check_spell_power(user, target);
	
	if randomize_flag_per_hit : cast.spell_flags.clear();
	
	for i in num_hits:
		_damage_loop(power, user, target, cast, result, crit, hit, index, i);
	
	cast.set_damage(result);
	cast.set_hits(hit);
	cast.set_critical(crit);
	cast.target_index_override = index;


func _damage_loop(power : float, user : EntityController, target : EntityController, cast : SpellCast, result : Array, crit : Array, hit : Array, index : Array, i : int):
	
	var flags = spell_flags.duplicate();
	
	if randomize_flag_per_hit :
		var random = randomized_flags.pick_random();
		flags = [random];
		cast.spell_flags.append(random);
		print(random.flag_name_key);
	
	var atk_type = spell_attack_type;
	
	if use_multihit_attack_type && multihit_attack_type != null && i < multihit_attack_type.size():
		atk_type = multihit_attack_type[i];
	
	var def_type = spell_attack_type;
	if vary_defense_type : def_type = spell_defense_type;
	
	if i > 0 && spell_target == SpellTarget.RandomEnemyPerHit :
		target = cached_targets[randi_range(0, cached_targets.size() - 1)];
	index.append(cached_targets.find(target));
	
	# I think this may be an unfair roll. 
	# It rolls once for the spell, and then again later for the first hit.
	if check_accuracy_per_hit && !check_spell_hit(cast, user, target, spell_accuracy_per_hit):
		hit.append(false);
		crit.append(false);
		result.append(0);
		return;
	else : 
		cast.clear_hit_result();
	
	hit.append(true);
	
	var damage = damage_roll(power, atk_type, def_type, user.level, user.param, user.get_attack_modifier(), user.get_sp_attack_modifier(), target.level, target.param, target.current_hp, target.get_defense_modifier(), target.get_sp_defense_modifier(), target.can_heal, crit);
	
	# Deals damage using a percentage of the target's current HP
	# Will never defeat an enemy except in very exceptional situations
	if fixed_damage && percent_damage :
		result.append(roundi(damage));
		return;
	# Deals damage using a percentage of the target's maximum HP
	# Use sparingly or for heals
	elif percent_damage : 
		result.append(roundi(damage));
		return;
	# Deals direct damage using the fixed damage amount
	elif fixed_damage : 
		result.append(roundi(damage));
		return;
	
	for flag in flags:
		if user.offense_modifiers.has(flag.flag_name_key):
			damage *= user.offense_modifiers[flag.flag_name_key];
		if target.defense_modifiers.has(flag.flag_name_key):
			damage *= target.defense_modifiers[flag.flag_name_key];
	
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
		if flags.has(flag):
			print("AFFINITY")
			damage *= AFFINITY_BONUS;
			break;
	
	print("Full Damage: " + str(damage))
	damage *= randf_range(0.85, 1.0);
	
	var critical = crit.back();
	if critical : damage *= 1.5
	
	if negate : 
		if target.can_heal : result.append(-roundi(damage));
		else : result.append(0);
	else : result.append(roundi(damage));


func damage_roll(power : float, atk_type : SpellHitType, def_type : SpellHitType, user_level : int, user_param : EntityParams, user_atk_mod : float, user_mag_mod : float, target_level : int, target_param : EntityParams, target_hp : int, target_def_mod : float, target_res_mod : float, target_can_heal : bool, crit : Array[bool]) -> float:
	# Deals damage using a percentage of the target's current HP
	# Will never defeat an enemy except in very exceptional situations
	if fixed_damage && percent_damage :
		crit.append(false);
		var percent = percent_damage_amt * target_hp;
		if negate : 
			if target_can_heal : return -roundi(percent);
			else : return 0;
		else : return roundi(percent);
	# Deals damage using a percentage of the target's maximum HP
	# Use sparingly or for heals
	elif percent_damage : 
		crit.append(false);
		var percent = percent_damage_amt * target_param.entity_hp;
		if negate : 
			if target_can_heal : return -roundi(percent);
			else : return 0;
		else : return roundi(percent);
	# Deals direct damage using the fixed damage amount
	elif fixed_damage : 
		crit.append(false);
		if negate : 
			if target_can_heal : return -fixed_damage_amt;
			else : return 0;
		else : return fixed_damage_amt;
	
	var crit_chance = 1;
	# Originally included to prevent negative luck but...
	# we kind of want that, no?
	#if user.param.entity_luck > 1 :
	crit_chance = user_param.entity_luck;
	# If user crit chance modifier is 0, user cannot crit
	if user_param.entity_crit_chance_modifier == 0 : crit_chance = 0;
	else : crit_chance *= user_param.entity_crit_chance_modifier;
	
	# If target crit resist modifier is 0, target cannot be crit
	if target_param.entity_crit_resist_modifier == 0 : crit_chance = 0;
	else : crit_chance /= target_param.entity_crit_resist_modifier;
	
	var critical = false;
	if critical_chance > 0 && can_critical:
		var chance = randf();
		critical = chance < ((1.0 / critical_chance) * crit_chance);
	crit.append(critical);
	
	var atk_mod = user_atk_mod;
	if atk_type == SpellHitType.Special: atk_mod = user_mag_mod;
	var def_mod = target_def_mod;
	if def_type == SpellHitType.Special: def_mod = target_res_mod;
	
	var atk = user_param.entity_atk;
	if atk_type == SpellHitType.Special : atk = user_param.entity_sp_atk;
	var def = target_param.entity_def;
	if def_type == SpellHitType.Special : def = target_param.entity_sp_def;
	
	if ignore_attack_stage : atk_mod = 1;
	if ignore_defense_stage : def_mod = 1;
	
	if critical && atk_mod < 1 : atk_mod = 1;
	if critical && def_mod > 1 : def_mod = 1;
	
	# Revised damage formula that takes into account user's level
	var damage = ((((user_level) as float) / 5.0) + 5.0) * power;
	if !ignore_target_defense :
		damage *= (((float)(atk * atk_mod)) / ((float)(def * def_mod)));
	else : 
		var relative_def = ((BASE_STAT * 2 * (user_level)) / 100) + 5;
		damage *= (((float)(atk * atk_mod)) / ((float)(relative_def * def_mod)));
	
	# Scale damage to a lower number range
	damage /= 10.0;
	
	return damage;


func check_spell_power(user : EntityController, target : EntityController) -> float :
	return spell_power;


func cast_overworld(user : int, target : int, preview : bool = false) -> int:
	super.cast_overworld(user, target, preview);
	
	var user_data = DataManager.party_data[user];
	var target_data = DataManager.party_data[target];
	
	var user_entity = DataManager.entity_database.get_entity(user_data.id);
	var target_entity = DataManager.entity_database.get_entity(target_data.id);
	
	var user_param = user_entity.create_entity_params(user_data.level);
	var target_param = target_entity.create_entity_params(target_data.level);
	
	# Check equipment
	var user_weapon = DataManager.item_database.get_item(user_data.weapon_id);
	var user_armor = DataManager.item_database.get_item(user_data.armor_id);
	var user_accessory = DataManager.item_database.get_item(user_data.accessory_id);
	var user_equipment = [user_weapon, user_armor, user_accessory];
	
	for e in user_equipment:
		if e != null:
			user_param.entity_hp += (e as EquipmentItem).hp_mod;
			user_param.entity_mp += (e as EquipmentItem).mp_mod;
			user_param.entity_atk += (e as EquipmentItem).atk_mod;
			user_param.entity_def += (e as EquipmentItem).def_mod;
			user_param.entity_sp_atk += (e as EquipmentItem).mag_mod;
			user_param.entity_sp_def += (e as EquipmentItem).res_mod;
			user_param.entity_spd += (e as EquipmentItem).spd_mod;
	
	var target_weapon = DataManager.item_database.get_item(target_data.weapon_id);
	var target_armor = DataManager.item_database.get_item(target_data.armor_id);
	var target_accessory = DataManager.item_database.get_item(target_data.accessory_id);
	var target_equipment = [target_weapon, target_armor, target_accessory];
	
	for e in target_equipment:
		if e != null:
			target_param.entity_hp += (e as EquipmentItem).hp_mod;
			target_param.entity_mp += (e as EquipmentItem).mp_mod;
			target_param.entity_atk += (e as EquipmentItem).atk_mod;
			target_param.entity_def += (e as EquipmentItem).def_mod;
			target_param.entity_sp_atk += (e as EquipmentItem).mag_mod;
			target_param.entity_sp_def += (e as EquipmentItem).res_mod;
			target_param.entity_spd += (e as EquipmentItem).spd_mod;
	
	var damage = (damage_roll(spell_power, spell_attack_type, spell_defense_type, user_data.level, user_param, 1.0, 1.0, target_data.level, target_param, target_data.hp_value, 1.0, 1.0, !target_data.status.has("Doom"), []));
	
	if target_data.hp_value - damage >= target_param.entity_hp:
		return -(target_param.entity_hp - target_data.hp_value);
	
	return damage;
