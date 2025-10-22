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
		if instance.user is EnemyController :
			if check_target == CheckTarget.Allies :
				num = BattleScene.Instance.get_num_active_enemies();
			else :
				num = BattleScene.Instance.get_num_active_players();
		else :
			if check_target == CheckTarget.Allies :
				num = BattleScene.Instance.get_num_active_players();
			else :
				num = BattleScene.Instance.get_num_active_enemies();
	
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
