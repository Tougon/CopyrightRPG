extends EffectFunction
class_name EFCheckStatStage

@export var target : EffectFunction.Target;
@export var stat : EffectFunction.Stat;
@export var check_mode : EffectFunction.CheckMode;
@export var stage : int;
@export var max : bool;
@export var min : bool;

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
		
		match stat : 
			EffectFunction.Stat.ATTACK: entity_stage = entity.atk_stage;
			EffectFunction.Stat.DEFENSE: entity_stage = entity.def_stage;
			EffectFunction.Stat.SPATTACK: entity_stage = entity.sp_atk_stage;
			EffectFunction.Stat.SPDEFENSE: entity_stage = entity.sp_def_stage;
			EffectFunction.Stat.SPEED: entity_stage = entity.spd_stage;
			EffectFunction.Stat.ACCURACY: entity_stage = entity.accuracy_stage_stage;
			EffectFunction.Stat.EVASION: entity_stage = entity.evasion_stage_stage;
		
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
