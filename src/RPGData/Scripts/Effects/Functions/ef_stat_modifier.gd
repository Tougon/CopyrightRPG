extends EffectFunction
class_name EFStatModifier

@export var target : EffectFunction.Target;
## If false, this command will instead remove this modifier.
@export var apply : bool = true;
@export var stat : EffectFunction.Stat;
@export var amount : float = 1;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	var name = instance.get_effect_name();
	
	if entity && !entity.is_defeated:
		match stat :
			EffectFunction.Stat.DEFENSE:
				if apply :
					if !entity.def_mods.has(name) : entity.def_mods[name] = amount
				else : 
					entity.def_mods.erase(name);
