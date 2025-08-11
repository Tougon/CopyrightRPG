extends EffectFunction
class_name EFSetSkipDecision

@export var target : EffectFunction.Target;
@export var skip_decision : bool;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity && !entity.is_defeated : 
		entity.skip_decision = skip_decision;
