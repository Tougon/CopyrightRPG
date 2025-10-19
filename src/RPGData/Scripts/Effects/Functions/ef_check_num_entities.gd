extends EffectFunction
class_name EFCheckNumEntities

enum CheckTarget {Self, Allies, Targets}

@export var target_number : int;
@export var check_target : CheckTarget;
@export var check_mode : EffectFunction.CheckMode;

func execute(instance : EffectInstance):
	var num = 0;
	
	if check_target == CheckTarget.Self:
		num = 1;
	else:
		var check_ec = instance.user.enemies;
		
		if check_target == CheckTarget.Allies:
			check_ec = instance.user.allies;
		
		var entities : Array[EntityController];
		
		for ec in check_ec:
			if !ec.is_defeated:
				num += 1;
	
	match check_mode:
		EffectFunction.CheckMode.LESS:
			instance.cast_success = num < target_number;
		EffectFunction.CheckMode.LESSEQUAL:
			instance.cast_success = num <= target_number;
		EffectFunction.CheckMode.EQUALS:
			instance.cast_success = num == target_number;
		EffectFunction.CheckMode.GREATER:
			instance.cast_success = num > target_number;
		EffectFunction.CheckMode.GREATEREQUAL:
			instance.cast_success = num >= target_number;
