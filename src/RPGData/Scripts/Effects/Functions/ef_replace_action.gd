extends EffectFunction
class_name EFReplaceAction

@export var target : EffectFunction.Target;
@export var action : Spell;
@export var reset_sealing : bool = true;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if (entity != null && action != null) :
		entity.current_action = action;
		
		if reset_sealing:
			entity.sealing = false;
