extends EffectFunction
class_name EFSetHeal

@export var target : EffectFunction.Target;
@export var can_heal : bool;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity && !entity.is_defeated : 
		entity.can_heal = can_heal;
