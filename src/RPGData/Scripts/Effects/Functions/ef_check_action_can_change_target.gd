extends EffectFunction
class_name EFCheckActionCanChangeTarget

@export var target : EffectFunction.Target;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	var action = entity.current_action;
	
	if action != null:
		instance.cast_success = action.spell_target == Spell.SpellTarget.SingleEnemy || action.spell_target == Spell.SpellTarget.SingleParty
		
		if instance.cast_success : 
			var targets = entity.get_possible_targets(action);
			instance.cast_success = targets.size() > 1;
