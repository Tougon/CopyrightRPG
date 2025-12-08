extends Resource

class_name EntityBehaviorCheck

enum CheckType {AND, OR}

## The checks that will run for this behavior. All of these checks must be true.
@export var behavior_check : Array[BehaviorCheck];
@export var check_type : CheckType;
## The randomized pool of actions to choose if the check is valid
@export var action_id : Array[int];
## Odds that determine if this action should be sealed
@export var seal_chance : Array[float];
## The randomized pool of seals to choose if the check is valid
@export var seal_id : Array[int];


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
		
		var rand = randf();
		
		if index < seal_chance.size() && rand <= seal_chance[index] && action_id[index] < user.move_list.size():
			var action = user.move_list[action_id[index]];
			
			for ally in allies:
				# NOTE: This originally checked if the ally's action is equal to the target
				# This would allow for the enemy to do multiple seals per turn.
				if ally.sealing :
					result.action_sealing = false;
					return result;
			
			result.action_sealing = BattleManager.seal_manager.can_seal_spell(action, user);
			result.action_seal_id = 0;
			
			# Originally this was random. Why.
			if result.action_sealing && seal_id.size() < index: 
				result.action_seal_id = seal_id[index];
	
	return result;
