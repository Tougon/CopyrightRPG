extends Resource

class_name EntityBehaviorCheck

enum CheckType {AND, OR}

## The checks that will run for this behavior. All of these checks must be true.
@export var behavior_check : Array[BehaviorCheck];
@export var check_type : CheckType;
## The randomized pool of actions to choose if the check is valid
@export var action_id : Array[int];
## Determine if this action should be sealed
@export var seal_id : Array[bool];


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
		var index = randi_range(0, action_id.size() - 1);
		result.action_success = true;
		result.action_id = action_id[index];
		
		if index < seal_id.size() && seal_id[index] && index < user.move_list.size():
			var action = user.move_list[index];
			
			for ally in allies:
				if ally.sealing && ally.current_action == action:
					result.action_sealing = false;
					return result;
			
			result.action_sealing = BattleManager.seal_manager.can_seal_spell(action);
	
	return result;
