extends BehaviorCheck

class_name BehaviorCheckHP

@export_range(0, 1) var hp_percent : float;
@export var randomize_target : bool;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	
	if check_target == CheckTarget.Self:
		result.trigger_entity = user;
		var percent_check = user.get_hp_percent() >= hp_percent;
		
		if negate:
			return !percent_check;
		else:
			return percent_check;
	else:
		var check_ec = targets;
		
		if check_target == CheckTarget.Allies:
			check_ec = allies;
		
		var entities : Array[EntityController];
		
		for ec in check_ec:
			var percent_check = ec.get_hp_percent() >= hp_percent;
			var val = false;
			
			if negate:
				val = !percent_check;
			else:
				val = percent_check;
			
			if val:
				result.trigger_entity = ec;
				if !randomize_target : return true;
				else : entities.append(ec);
		
		if randomize_target && entities.size() > 0 :
			result.trigger_entity = entities.pick_random();
			return true;
		
	return false;
