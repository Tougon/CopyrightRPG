extends EffectFunction
class_name EFRemoveEffect

@export var target : EffectFunction.Target;
@export var effect : Effect;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity :
		var inst = entity.remove_effect_from_resource(effect)
