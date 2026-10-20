extends EffectFunction
class_name EFChangePriority

@export var target : EffectFunction.Target;
@export_range(-5, 5) var amount : int = 0;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	entity.override_priority = true;
	entity.override_priority_value = amount;
