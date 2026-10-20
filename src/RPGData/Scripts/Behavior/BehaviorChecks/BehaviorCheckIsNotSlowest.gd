extends BehaviorCheck

class_name BehaviorCheckIsNotSlowest


func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	if check_target == CheckTarget.Self:
		return false;
	else:
		var check_ec = targets;
		
		if check_target == CheckTarget.Allies:
			check_ec = allies;
		
		var entities : Array[EntityController];
		
		for entity in check_ec :
			if entity == user : continue;
			
			var speed_comp = EntityController.compare_speed(user, entity);
			if speed_comp :
				entities.append(entity);
		
		if entities.size() > 0 :
			result.trigger_entity = entities.pick_random();
			return true;
		else :
			return false;
