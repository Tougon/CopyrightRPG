extends Resource

class_name EntityBehaviorCheck

enum CheckType {AND, OR}

## The checks that will run for this behavior. All of these checks must be true.
@export var behavior_check : Array[BehaviorCheck];
@export var check_type : CheckType;
## The randomized pool of actions to choose if the check is valid
@export var action_id : Array[int];


func determine_action(user : EntityController, allies : Array[EntityController], targets : Array[EntityController]) -> BehaviorCheckResult:
	var result = BehaviorCheckResult.new(user);
	
	var success = true;
	
	for i in behavior_check.size():
		success = behavior_check[i].check(user, allies, targets, result);
		
		if check_type == CheckType.AND && !success:
			break;
		
		if check_type == CheckType.OR && success:
			break;
	
	if success:
		result.action_success = true;
		result.action_id = action_id[randi_range(0, action_id.size() - 1)];
	
	return result;
