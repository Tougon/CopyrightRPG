extends EffectFunction
class_name EFRemoveEffect

@export var target : EffectFunction.Target;
@export var effect : Effect;
@export var use_effect_name : bool = false;
@export var effect_name : String;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity :
		if use_effect_name :
			entity.remove_effect_from_name(effect_name)
		else : 
			entity.remove_effect_from_resource(effect)
