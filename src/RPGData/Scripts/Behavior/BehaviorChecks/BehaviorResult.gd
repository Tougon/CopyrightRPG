extends Object

class_name BehaviorCheckResult

var action_id : int;
var action_success : bool;
var action_sealing : bool;
var trigger_entity: EntityController;
var check_target : BehaviorCheck.CheckTarget;

func _init(entity : EntityController):
	action_success = false;
	action_id = -1;
	trigger_entity = entity;
