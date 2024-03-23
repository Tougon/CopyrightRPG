extends EffectFunction
class_name EFChangeStatStage

@export var target : EffectFunction.Target;
@export var stat : EffectFunction.Stat;
@export var amount : int;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity != null:
		
		match stat : 
			EffectFunction.Stat.ATTACK: entity.atk_stage = clampi(entity.atk_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.DEFENSE: entity.def_stage = clampi(entity.def_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.SPATTACK: entity.sp_atk_stage = clampi(entity.sp_atk_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.SPDEFENSE: entity.sp_def_stage = clampi(entity.sp_def_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.SPEED: entity.spd_stage = clampi(entity.spd_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.ACCURACY: entity.accuracy_stage_stage = clampi(entity.accuracy_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
			EffectFunction.Stat.EVASION: entity.evasion_stage = clampi(entity.evasion_stage + amount, -entity.STAT_STAGE_LIMIT, entity.STAT_STAGE_LIMIT);
