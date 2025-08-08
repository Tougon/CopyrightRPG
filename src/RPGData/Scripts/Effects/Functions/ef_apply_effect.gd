extends EffectFunction
class_name EFApplyEffect

@export var target : EffectFunction.Target;
@export var effect : Effect;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity:
		var inst = effect.create_effect_instance(instance.user, instance.target, instance.spell);
		
		inst.check_success();
		
		if inst.cast_success: 
			inst.on_activate();
		else :
			inst.on_failed_to_activate();
		
		if !inst.applied : inst.free();
