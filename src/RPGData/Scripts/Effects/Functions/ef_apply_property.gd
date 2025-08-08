# NOTE: This is all old code and will not work. If we need this later, rework.
extends EffectFunction
class_name EFApplyProperty

@export var target : EffectFunction.Target;
@export var property : Effect;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity:
		var prop_inst = property.create_effect_instance(instance.user, instance.target, instance.spell);
		prop_inst.turns_active = instance.turns_active;
		entity.add_property(prop_inst);
