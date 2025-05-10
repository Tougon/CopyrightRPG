extends EffectFunction
class_name EFReplaceDefaultDefend

@export var action : Spell;

func execute(instance : EffectInstance):
	var entity : EntityController = instance.user;
	
	if (entity != null && action != null) :
		entity.defend_action = action;
