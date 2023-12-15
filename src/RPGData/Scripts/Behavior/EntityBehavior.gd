extends Resource

class_name EntityBehavior

@export var behavior_checks : Array[EntityBehaviorCheck];

func get_result (user : EntityController, allies : Array[EntityController], targets : Array[EntityController]) -> BehaviorCheckResult:
	for behavior in behavior_checks:
		var result = behavior.determine_action(user, allies, targets);
		
		if result.action_success:
			return result;
	
	return BehaviorCheckResult.new(user);
