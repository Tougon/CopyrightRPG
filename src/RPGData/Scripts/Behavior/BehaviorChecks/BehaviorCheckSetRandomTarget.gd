extends BehaviorCheck

class_name BehaviorCheckSetRandomTarget

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	result.trigger_entity = targets.pick_random();
	result.check_target = check_target;
	return true;
