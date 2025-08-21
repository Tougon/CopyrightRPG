extends EffectFunction
class_name EFCheckStatStage

@export var target : EffectFunction.Target;
@export var stat : EffectFunction.Stat;
@export var check_mode : EffectFunction.CheckMode;
@export var stage : int;
@export var max : bool;
@export var min : bool;
@export var use_stage : bool;
@export var use_modifiers : bool;

func execute(instance : EffectInstance):
	var check_stage = stage;
	
	if max: check_stage = EntityController.STAT_STAGE_LIMIT;
	elif min: check_stage = -EntityController.STAT_STAGE_LIMIT;
	
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity != null:
		var entity_stage = 0;
		
		var target_stat = stat;
		
		if target_stat == EffectFunction.Stat.LOWEST || target_stat == EffectFunction.Stat.HIGHEST :
			target_stat = _get_highest_or_lowest_stat(entity);
			print("RESULT: " + str(target_stat))
		
		if target_stat == EffectFunction.Stat.RANDOM :
			var possible_stats = [ EffectFunction.Stat.ATTACK, EffectFunction.Stat.DEFENSE, EffectFunction.Stat.SPATTACK, EffectFunction.Stat.SPDEFENSE, EffectFunction.Stat.SPEED ];
			target_stat = possible_stats.pick_random();
			instance.data["stat"] = target_stat;
		
		match target_stat : 
			EffectFunction.Stat.ATTACK: entity_stage = entity.atk_stage;
			EffectFunction.Stat.DEFENSE: entity_stage = entity.def_stage;
			EffectFunction.Stat.SPATTACK: entity_stage = entity.sp_atk_stage;
			EffectFunction.Stat.SPDEFENSE: entity_stage = entity.sp_def_stage;
			EffectFunction.Stat.SPEED: entity_stage = entity.spd_stage;
			EffectFunction.Stat.ACCURACY: entity_stage = entity.accuracy_stage;
			EffectFunction.Stat.EVASION: entity_stage = entity.evasion_stage;
		
		match check_mode :
			EffectFunction.CheckMode.EQUALS:
				if entity_stage == check_stage:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.GREATER:
				if entity_stage > check_stage:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.GREATEREQUAL:
				if entity_stage >= check_stage:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.LESS:
				if entity_stage < check_stage:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.LESSEQUAL:
				if entity_stage <= check_stage:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
		
	else : instance.cast_success = false;


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
