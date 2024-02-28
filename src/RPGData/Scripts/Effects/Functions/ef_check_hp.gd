extends EffectFunction
class_name EFCheckHP

@export var target : EffectFunction.Target;
@export var check_mode : EffectFunction.CheckMode;
@export_range(0, 1) var health_percent : float;
@export var use_amount : bool = false;
@export var health_amount : float;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity != null:
		match check_mode :
			EffectFunction.CheckMode.EQUALS:
				if (use_amount && health_amount == entity.current_hp) || (!use_amount && health_percent == entity.get_hp_percent()):
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.GREATER:
				if (use_amount && health_amount < entity.current_hp) || (!use_amount && health_percent < entity.get_hp_percent()):
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.GREATEREQUAL:
				if (use_amount && health_amount <= entity.current_hp) || (!use_amount && health_percent <= entity.get_hp_percent()):
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.LESS:
				if (use_amount && health_amount > entity.current_hp) || (!use_amount && health_percent > entity.get_hp_percent()):
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.LESSEQUAL:
				if (use_amount && health_amount >= entity.current_hp) || (!use_amount && health_percent >= entity.get_hp_percent()):
					instance.cast_success = true;
				else:
					instance.cast_success = false;
