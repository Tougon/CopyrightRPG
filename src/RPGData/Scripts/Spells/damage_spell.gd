@tool
extends Spell
class_name DamageSpell

const ACCURACY_BONUS : int = 10;

enum SpellHitType { Physical, Special }

@export_group("Base Damage Spell Parameters")
@export_range(0, 250) var spell_power : float = 50;
@export var spell_attack_type : SpellHitType;
@export var vary_defense_type : bool = false;
@export var spell_defense_type : SpellHitType;

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


func check_spell_hit(user : EntityController, target : EntityController, amt : float = -1):
	if amt == -1 && !check_accuracy : return true;
	
	var accuracy = user.get_accuracy();
	# TODO: Implement evasion modifiers?
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
	
	var result = (randf() * 100) <= hit;
	
	# TODO: Check if result failed and use that to handle the miss messaging
	
	return result;


func calculate_damage(user : EntityController, target : EntityController, cast : SpellCast):
	var num_hits = min_number_of_hits;
	
	if vary_hit_count :
		if min_number_of_hits > max_number_of_hits :
			min_number_of_hits = max_number_of_hits;
		
		var luck = 1;
		if user.param.entity_luck > 1:
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
		
		# This has a TODO in the original project but like...I dunno, fam. Seems fine to me
		# Though I do think this may be an unfair roll. 
		# Like, it rolls once for the spell, and then again later for the first hit.
		if check_accuracy_per_hit && !check_spell_hit(user, target, spell_accuracy_per_hit):
			hit.append(false);
			crit.append(false);
			result.append(0);
			continue;
		
		hit.append(true);
		
		# TODO: Defender crit modifiers to protect against critical hits
		var crit_chance = 1;
		if user.param.entity_luck > 1 :
			crit_chance = user.param.entity_luck;
		if user.param.entity_crit_modifier == 0 : crit_chance = 0;
		else : crit_chance / user.param.entity_crit_modifier;
		
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
		
		if critical && atk_mod < 1 : atk_mod = 1;
		if critical && def_mod > 1 : def_mod = 1;
		
		var damage = ((((2 * user.level) / 5) + 2) * spell_power * ((atk * atk_mod) / (def * def_mod))) / 50.0;

		var atk_mods_post = user.get_attack_modifiers();
		if atk_type == SpellHitType.Special: atk_mods_post = user.get_sp_attack_modifiers();
		var def_mods_post = target.get_defense_modifiers();
		if def_type == SpellHitType.Special: def_mods_post = target.get_sp_defense_modifier();
		
		for f in atk_mods_post :
			damage *= f;
		for f in def_mods_post:
			damage /= f;
		
		damage *= randf_range(0.85, 1.0);
		
		if critical : damage *= 1.5
		
		result.append(roundi(damage));
	
	cast.set_damage(result);
	cast.set_hits(hit);
	cast.set_critical(crit);
	cast.target_index_override = index;
