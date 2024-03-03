extends EffectFunction
class_name EFCheckActive

@export var target : EffectFunction.Target;

func execute(instance : EffectInstance):
	instance.check_remain_active();
	
	if !instance.cast_success:
		var entity : EntityController;
		if target == Target.USER:
			entity = instance.user;
		elif target == Target.TARGET:
			entity = instance.target;
		
		if entity : entity.remove_effect(instance);
