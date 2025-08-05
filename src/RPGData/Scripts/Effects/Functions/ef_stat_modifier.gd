extends EffectFunction
class_name EFStatModifier

@export var target : EffectFunction.Target;
## If false, this command will instead remove this modifier.
@export var apply : bool = true;
@export var stat : EffectFunction.Stat;
@export var amount : float = 1;
@export var use_num_targets : bool = false;
@export var min_amount : float = 0;
@export var max_amount : float = 1;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	var name = instance.get_effect_name();
	
	var mod_amount = amount;
	
	if use_num_targets :
		var targets = (entity.get_possible_targets().size() - 1) as float;
		mod_amount = lerpf(min_amount, max_amount, targets / ((BattleManager.MAX_ENEMY_COUNT -1) as float));
	
	if entity && !entity.is_defeated:
		match stat :
			EffectFunction.Stat.ATTACK:
				if apply :
					if !entity.atk_mods.has(name) : entity.atk_mods[name] = mod_amount
				else : 
					entity.atk_mods.erase(name);
			
			EffectFunction.Stat.DEFENSE:
				if apply :
					if !entity.def_mods.has(name) : entity.def_mods[name] = mod_amount
				else : 
					entity.def_mods.erase(name);
			
			EffectFunction.Stat.SPATTACK:
				if apply :
					if !entity.sp_atk_mods.has(name) : entity.sp_atk_mods[name] = mod_amount
				else : 
					entity.sp_atk_mods.erase(name);
			
			EffectFunction.Stat.SPDEFENSE:
				if apply :
					if !entity.sp_def_mods.has(name) : entity.sp_def_mods[name] = mod_amount
				else : 
					entity.sp_def_mods.erase(name);
			
			EffectFunction.Stat.SPEED:
				if apply :
					if !entity.spd_mods.has(name) : entity.spd_mods[name] = mod_amount
				else : 
					entity.spd_mods.erase(name);
			
			EffectFunction.Stat.ACCURACY:
				if apply :
					if !entity.accuracy_mods.has(name) : entity.accuracy_mods[name] = mod_amount
				else : 
					entity.accuracy_mods.erase(name);
			
			EffectFunction.Stat.EVASION:
				if apply :
					if !entity.evasion_mods.has(name) : entity.evasion_mods[name] = mod_amount
				else : 
					entity.evasion_mods.erase(name);
