extends Resource

class_name EntityBehavior

@export var behavior_checks : Array[EntityBehaviorCheck];
@export var active_condition : Array[BehaviorCheck];

func get_result (user : EntityController, allies : Array[EntityController], targets : Array[EntityController]) -> BehaviorCheckResult:
	for behavior in behavior_checks:
		var result = behavior.determine_action(user, allies, targets);
		
		if result.action_success:
			return result;
	
	return BehaviorCheckResult.new(user);


func is_behavior_active(user : EntityController, allies : Array[EntityController], targets : Array[EntityController]) -> bool:
	for condition in active_condition:
		if !condition.check(user, allies, targets, BehaviorCheckResult.new(user)):
			return false;
	
	return true;
