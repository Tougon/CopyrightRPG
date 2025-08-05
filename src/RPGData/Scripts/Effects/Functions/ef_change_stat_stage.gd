extends EffectFunction
class_name EFChangeStatStage

@export var target : EffectFunction.Target;
@export var stat : EffectFunction.Stat;
@export var amount : int;
@export var use_stage : bool;
@export var use_modifiers : bool;
@export var cache_stat : bool;
@export var activation_strings : Array[String];
@export var deactivation_strings : Array[String];

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity != null:
		
		var target_stat = stat;
		
		if target_stat == EffectFunction.Stat.CACHE : 
			target_stat = instance.data["stat"];
			print("USING CACHED STAT: " + str(target_stat));
		
		if target_stat == EffectFunction.Stat.LOWEST || target_stat == EffectFunction.Stat.HIGHEST :
			target_stat = _get_highest_or_lowest_stat(entity);
		
		if cache_stat : 
			instance.data["stat"] = target_stat;
			instance.data["hybrid_key"] = _get_activation_string(target_stat);
			instance.data["dialogue_key"] = _get_removal_string(target_stat);
		
		match target_stat : 
			EffectFunction.Stat.ATTACK: entity.atk_stage = clampi(entity.atk_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.DEFENSE: entity.def_stage = clampi(entity.def_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.SPATTACK: entity.sp_atk_stage = clampi(entity.sp_atk_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.SPDEFENSE: entity.sp_def_stage = clampi(entity.sp_def_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.SPEED: entity.spd_stage = clampi(entity.spd_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.ACCURACY: entity.accuracy_stage_stage = clampi(entity.accuracy_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.EVASION: entity.evasion_stage = clampi(entity.evasion_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);


func _get_activation_string(target_stat : EffectFunction.Stat) -> String :
	if activation_strings.size() > 0:
		match target_stat : 
			EffectFunction.Stat.ATTACK: 
				if activation_strings.size() > 0 : return activation_strings[0];
				else : return activation_strings[activation_strings.size() - 1];
			EffectFunction.Stat.DEFENSE:
				if activation_strings.size() > 1 : return activation_strings[1];
				else : return activation_strings[activation_strings.size() - 1];
			EffectFunction.Stat.SPATTACK: 
					if activation_strings.size() > 2 : return activation_strings[2];
					else : return activation_strings[activation_strings.size() - 1];
			EffectFunction.Stat.SPDEFENSE: 
				if activation_strings.size() > 3 : return activation_strings[3];
				else : return activation_strings[activation_strings.size() - 1];
			EffectFunction.Stat.SPEED: 
				if activation_strings.size() > 4 : return activation_strings[4];
				else : return activation_strings[activation_strings.size() - 1];
	
	return "";


func _get_removal_string(target_stat : EffectFunction.Stat) -> String :
	if deactivation_strings.size() > 0:
		match target_stat : 
			EffectFunction.Stat.ATTACK: 
				if deactivation_strings.size() > 0 : return deactivation_strings[0];
				else : return deactivation_strings[deactivation_strings.size() - 1];
			EffectFunction.Stat.DEFENSE:
				if deactivation_strings.size() > 1 : return deactivation_strings[1];
				else : return deactivation_strings[deactivation_strings.size() - 1];
			EffectFunction.Stat.SPATTACK: 
					if deactivation_strings.size() > 2 : return deactivation_strings[2];
					else : return deactivation_strings[deactivation_strings.size() - 1];
			EffectFunction.Stat.SPDEFENSE: 
				if deactivation_strings.size() > 3 : return deactivation_strings[3];
				else : return deactivation_strings[deactivation_strings.size() - 1];
			EffectFunction.Stat.SPEED: 
				if deactivation_strings.size() > 4 : return deactivation_strings[4];
				else : return deactivation_strings[deactivation_strings.size() - 1];
	
	return "";


func _get_highest_or_lowest_stat(entity : EntityController) -> EffectFunction.Stat :
	var atk = entity.param.entity_atk;
	var def = entity.param.entity_def;
	var mag = entity.param.entity_sp_atk;
	var res = entity.param.entity_sp_def;
	var spd = entity.param.entity_spd;
	
	var index = 4;
	if stat == EffectFunction.Stat.LOWEST : index = 0;
	
	if use_stage : 
		atk *= entity.get_attack_modifier();
		def *= entity.get_defense_modifier();
		mag *= entity.get_sp_attack_modifier();
		res *= entity.get_sp_defense_modifier();
		spd *= entity.get_speed_modifier();
	
	if use_modifiers : 
		var atk_mods = entity.get_attack_modifiers();
		for mod in atk_mods : 
			atk *= mod;
		
		var def_mods = entity.get_defense_modifiers();
		for mod in def_mods : 
			def *= mod;
		
		var mag_mods = entity.get_sp_attack_modifiers();
		for mod in mag_mods : 
			mag *= mod;
		
		var res_mods = entity.get_sp_defense_modifiers();
		for mod in res_mods : 
			res *= mod;
		
		var spd_mods = entity.get_speed_modifiers();
		for mod in spd_mods : 
			spd *= mod;
	
	var stats = [atk, def, mag, res, spd];
	stats.sort();
	
	if atk == stats[index] : return EffectFunction.Stat.ATTACK;
	if def == stats[index] : return EffectFunction.Stat.DEFENSE;
	if mag == stats[index] : return EffectFunction.Stat.SPATTACK;
	if res == stats[index] : return EffectFunction.Stat.SPDEFENSE;
	if spd == stats[index] : return EffectFunction.Stat.SPEED;
	
	print("ERROR: Defaulting to Attack")
	return EffectFunction.Stat.ATTACK;
