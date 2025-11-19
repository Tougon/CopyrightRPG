extends BehaviorCheck

class_name BehaviorCheckTarget

@export var target : Entity;
@export var default_state : bool;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	if result.trigger_entity :
		var state = result.trigger_entity.current_entity == target;
		
		if negate :
			return !state;
		else :
			return state;
	
	return default_state;
