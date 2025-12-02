extends BehaviorCheck

class_name BehaviorCheckAttackHighest

@export var use_stages : bool = true;
@export var use_modifiers : bool = false;
@export var phys_higher : bool = true;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	result.check_target = check_target;
	if check_target == CheckTarget.Self:
		
		var atk = user.param.entity_atk as float;
		var mag = user.param.entity_sp_atk as float;
		
		if use_stages :
			var atk_stage = user.get_attack_modifier();
			atk *= atk_stage;
			
			var mag_stage = user.get_sp_attack_modifier();
			mag *= mag_stage;
			
		if use_modifiers : 
			for mod in user.get_attack_modifiers():
				atk *= mod;
			
			for mod in user.get_sp_attack_modifiers():
				mag *= mod;
		
		if phys_higher :
			if negate : return mag > atk;
			else : return atk > mag;
		else :
			if negate : return atk > mag;
			else : return mag > atk;
		
		return false;
	
	return false;
