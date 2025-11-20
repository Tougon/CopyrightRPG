extends BehaviorCheck

class_name BehaviorCheckSetTarget

@export var entity : Entity;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	for target in targets :
		if target.current_entity == entity :
			result.trigger_entity = target;
			result.check_target = check_target;
			return true;
	
	return false;
