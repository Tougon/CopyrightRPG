extends BehaviorCheck

class_name BehaviorCheckDefenseLowest

@export var use_stages : bool = true;
@export var use_modifiers : bool = false;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	result.check_target = check_target;
	if check_target == CheckTarget.Self:
		return !negate;
	else:
		var check_ec = targets;
		
		if check_target == CheckTarget.Allies:
			check_ec = allies;
		
		var value = -1.0;
		var entities : Array[EntityController];
		
		for ec in check_ec:
			var defense = ec.param.entity_def as float;
			
			if use_stages :
				var stage = ec.get_defense_modifier();
				defense *= stage;
			
			if use_modifiers : 
				for mod in ec.get_defense_modifiers():
					defense *= mod;
			
			if negate :
				if value == -1:
					value = defense;
					entities.append(ec);
				else : 
					if defense > value :
						value = defense;
						entities.clear();
						entities.append(ec);
					elif defense == value :
						entities.append(ec);
			else:
				if value == -1:
					value = defense;
					entities.append(ec);
				else : 
					if defense < value :
						value = defense;
						entities.clear();
						entities.append(ec);
					elif defense == value :
						entities.append(ec);
		
		if entities.size() > 0 :
			result.trigger_entity = entities.pick_random();
			return true;
		
	return false;
