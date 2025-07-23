extends EffectFunction
class_name EFCheckIsUsingItem

@export var target : EffectFunction.Target;
@export var invert : bool = false;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	instance.cast_success = entity.current_item != null;
	if invert : instance.cast_success = !instance.cast_success;
