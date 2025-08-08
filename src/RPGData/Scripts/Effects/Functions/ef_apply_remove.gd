extends EffectFunction
class_name EFApplyRemove

@export var target : EffectFunction.Target;
## If false, this command will instead remove this effect.
@export var apply : bool = true;
## Only used if apply is false. If true, will deactivate the effect while removing it.
@export var deactivate : bool = true;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if apply : 
		entity.apply_effect(instance);
		instance.applied = true;
	else : entity.remove_effect(instance, deactivate);
