extends BehaviorCheck

class_name BehaviorCheckTarget

@export var target : Entity;
@export var target_id : int = -1;
@export var default_state : bool;
@export var use_self : bool;
@export var check_all : bool = false;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	var entity = target;
	if use_self : entity = user.current_entity;
	
	if entity == null && target_id >= 0 :
		entity = DataManager.entity_database.get_entity(target_id);
	
	if check_target == CheckTarget.Self:
		var state = user.current_entity == entity;
		
		if negate : 
			return !state;
		else :
			return state;
	elif check_target == CheckTarget.Allies:
		var all_same = true;
		
		for ally in allies :
			var state = ally.current_entity == entity;
			
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
		var state = result.trigger_entity.current_entity == entity;
		result.check_target = check_target;
		
		if negate :
			return !state;
		else :
			return state;
	
	return default_state;
