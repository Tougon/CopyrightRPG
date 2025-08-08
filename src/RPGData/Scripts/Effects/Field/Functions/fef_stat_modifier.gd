extends FieldEffectFunction
class_name FEFStatModifier

@export var side : FieldEffectFunction.Side;
## If false, this command will instead remove this modifier.
@export var apply : bool = true;
@export var stat : EffectFunction.Stat;
@export var amount : float = 1;

func execute(field_effect : FieldEffect, players : Array[EntityController], enemies : Array[EntityController]):
	var name = field_effect.effect_name;
	
	var mod_amount = amount;
	var targets : Array[EntityController] = [];
	
	match side:
		FieldEffectFunction.Side.BOTH:
			targets.append_array(players);
			targets.append_array(enemies);
		FieldEffectFunction.Side.PLAYER:
			targets.append_array(players);
		FieldEffectFunction.Side.ENEMY:
			targets.append_array(enemies);
	
	for entity in targets : 
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
