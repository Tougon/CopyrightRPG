extends EffectFunction
class_name EFCheckAction

@export var target : EffectFunction.Target;
@export var check_type : bool = false;
@export var target_type : Spell.SpellType;
@export var target_action : Spell;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	var action = entity.current_action;
	
	if action != null:
		if target_action != null : 
			instance.cast_success = target_action == action;
		else :
			if check_type :
				instance.cast_success = action.spell_type == target_type;
