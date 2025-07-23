extends EffectFunction
class_name EFSetSeal

@export var target : EffectFunction.Target;
@export var can_seal : bool;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity : 
		entity.seals_active = can_seal;
