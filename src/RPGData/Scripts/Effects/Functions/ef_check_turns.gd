extends EffectFunction
class_name EFCheckTurns

@export var check_mode : EffectFunction.CheckMode;
@export var use_limit : bool = true;
@export var turns : int = 3;

func execute(instance : EffectInstance):
	match check_mode :
		EffectFunction.CheckMode.EQUALS:
			if (use_limit && instance.turns_active == instance.turn_limit) || (!use_limit && instance.turns_active == turns):
				instance.cast_success = true;
			else:
				instance.cast_success = false;
		
		EffectFunction.CheckMode.GREATER:
			if (use_limit && instance.turns_active > instance.turn_limit) || (!use_limit && instance.turns_active > turns):
				instance.cast_success = true;
			else:
				instance.cast_success = false;
		
		EffectFunction.CheckMode.GREATEREQUAL:
			if (use_limit && instance.turns_active >= instance.turn_limit) || (!use_limit && instance.turns_active >= turns):
				instance.cast_success = true;
			else:
				instance.cast_success = false;
		
		EffectFunction.CheckMode.LESS:
			if (use_limit && instance.turns_active < instance.turn_limit) || (!use_limit && instance.turns_active < turns):
				instance.cast_success = true;
			else:
				instance.cast_success = false;
		
		EffectFunction.CheckMode.LESSEQUAL:
			if (use_limit && instance.turns_active <= instance.turn_limit) || (!use_limit && instance.turns_active <= turns):
				instance.cast_success = true;
			else:
				instance.cast_success = false;
