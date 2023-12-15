extends BehaviorCheck

class_name BehaviorCheckEffect

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	result.check_target = check_target;
	result.trigger_entity = null;
	return !negate;
