extends BehaviorCheck

class_name BehaviorCheckEffect

@export var target : EffectFunction.Target;
@export var effect : Effect;
@export var randomize_target : bool;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	result.check_target = check_target;
	
	if check_target == CheckTarget.Self:
		result.trigger_entity == user;
		if user.has_effect(effect.effect_name) :
			return !negate;
		else :
			return negate;
	else :
		var check_ec = targets;
		
		if check_target == CheckTarget.Allies:
			check_ec = allies;
		
		var entities : Array[EntityController];
		
		for ec in check_ec:
			if ec.has_effect(effect.effect_name) && !negate:
				entities.append(ec);
			elif !ec.has_effect(effect.effect_name) && negate:
				entities.append(ec);
			
			if !randomize_target && entities.size() > 0 :
				result.trigger_entity = entities[0];
				return true;
		
		if randomize_target && entities.size() > 0 :
			result.trigger_entity = entities.pick_random();
			return true;
	
	result.trigger_entity = null;
	return negate;
