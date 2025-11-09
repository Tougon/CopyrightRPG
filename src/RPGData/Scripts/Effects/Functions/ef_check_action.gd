extends EffectFunction
class_name EFCheckAction

@export var target : EffectFunction.Target;
@export var check_previous : bool = false;
@export var check_type : bool = false;
@export var target_type : Spell.SpellType;
@export var target_action : Spell;
@export var use_current_as_target : bool = false;
@export var invert : bool = false;
@export var default_result : bool = true;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	var action = entity.current_action;
	if check_previous : action = entity.prev_action;
	
	var check_action = target_action;
	if use_current_as_target : check_action = entity.current_action;
	
	if action != null:
		if check_action != null : 
			instance.cast_success = check_action == action;
		else :
			if check_type :
				instance.cast_success = action.spell_type == target_type;
	else :
		instance.cast_success = default_result;
	
	if invert : 
		instance.cast_success = !instance.cast_success;
