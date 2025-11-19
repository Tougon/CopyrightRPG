extends BehaviorCheck

class_name BehaviorCheckStatStage

@export var target_stat : EffectFunction.Stat;
@export_range(0, 1) var stat_amount : int;
@export var check_mode : EffectFunction.CheckMode;
@export var randomize_target : bool = false;


func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	
	if check_target == CheckTarget.Self:
		result.trigger_entity = user;
		var stat_check = check_stat_stage(user);
		
		if negate:
			return !stat_check;
		else:
			return stat_check;
	else:
		var check_ec = targets;
		
		if check_target == CheckTarget.Allies:
			check_ec = allies;
		
		var entities : Array[EntityController];
		
		for ec in check_ec:
			var stat_check = check_stat_stage(ec);
			var val = false;
			
			if negate:
				val = !stat_check;
			else:
				val = stat_check;
			
			if val:
				result.trigger_entity = ec;
				if !randomize_target : return true;
				else : entities.append(ec);
		
		if randomize_target && entities.size() > 0 :
			result.trigger_entity = entities.pick_random();
			return true;
	
	return false;


func check_stat_stage(entity : EntityController) -> bool :
	var entity_stage = 0;
	
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
			if entity_stage == stat_amount:
				return true;
			else:
				return false;
		
		EffectFunction.CheckMode.GREATER:
			if entity_stage > stat_amount:
				return true;
			else:
				return false;
		
		EffectFunction.CheckMode.GREATEREQUAL:
			if entity_stage >= stat_amount:
				return true;
			else:
				return false;
		
		EffectFunction.CheckMode.LESS:
			if entity_stage < stat_amount:
				return true;
			else:
				return false;
		
		EffectFunction.CheckMode.LESSEQUAL:
			if entity_stage <= stat_amount:
				return true;
			else:
				return false;
	 
	return false;
