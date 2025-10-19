extends BehaviorCheck

class_name BehaviorCheckNumEntities

enum CheckType {Less, LessEqual, Equal, GreaterEqual, Greater}

@export var target_number : int;
@export var check_type : CheckType;
@export var use_scaled : bool = false;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	var num = 0;
	
	if check_target == CheckTarget.Self:
		if !negate :
			num = 1;
	else:
		var check_ec = targets;
		
		if check_target == CheckTarget.Allies:
			check_ec = allies;
		
		var entities : Array[EntityController];
		
		for ec in check_ec:
			if (negate && ec.is_defeated) || (!negate && !ec.is_defeated):
				num += 1;
	
	if use_scaled :
		if check_target == CheckTarget.Allies :
			var target = (clamp(target_number - num, 0, target_number) as float) / (target_number as float);
			var random = randf()
			
			match check_type:
				CheckType.Less:
					return random < target;
				CheckType.LessEqual:
					return random <= target;
				CheckType.Equal:
					return random == target;
				CheckType.Greater:
					return random > target;
				CheckType.GreaterEqual:
					return random >= target;
	
	match check_type:
		CheckType.Less:
			return num < target_number;
		CheckType.LessEqual:
			return num <= target_number;
		CheckType.Equal:
			return num == target_number;
		CheckType.Greater:
			return num > target_number;
		CheckType.GreaterEqual:
			return num >= target_number;
	
	return false;
