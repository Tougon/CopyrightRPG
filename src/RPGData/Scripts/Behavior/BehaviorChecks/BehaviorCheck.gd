extends Resource

class_name BehaviorCheck

enum CheckTarget {Self, Allies, Targets}

@export var check_target : CheckTarget;
@export var negate : bool;


func check(user : EntityController, allies : EntityController, targets : EntityController, result : BehaviorCheckResult) -> bool:
	result.check_target = check_target;
	result.trigger_entity = null;
	return !negate;
