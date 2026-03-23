extends BehaviorCheck

class_name BehaviorCheckTargetUsingMove

@export var default_state : bool;
@export var check_all : bool = false;
@export var move : Spell;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	if check_target == CheckTarget.Allies:
		var all_same = true;
		
		for ally in allies :
			var state = ally.current_action == move;
			
			if check_all :
				if !state : all_same = false;
			else :
				if state :
					if negate :
						return !state;
					else :
						return state;
		
		if !check_all :
			return negate;
		
		if negate :
			return !all_same;
		else :
			return all_same;
	
	if result.trigger_entity :
		var state = result.trigger_entity.current_action == move;
		result.check_target = check_target;
		
		if negate :
			return !state;
		else :
			return state;
	
	return default_state;
