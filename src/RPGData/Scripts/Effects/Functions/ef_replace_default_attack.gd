extends EffectFunction
class_name EFReplaceDefaultAttack

@export var action : Spell;

func execute(instance : EffectInstance):
	var entity : EntityController = instance.user;
	
	if (entity != null && action != null) :
		entity.attack_action = action;
