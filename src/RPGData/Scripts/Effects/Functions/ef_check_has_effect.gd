extends EffectFunction
class_name EFCheckHasEffect

@export var target : EffectFunction.Target;
@export var effect : Effect;
@export var invert : bool = false;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity != null :
		instance.cast_success = entity.has_effect(effect.effect_name)
	
	if invert :
		instance.cast_success = !instance.cast_success;
