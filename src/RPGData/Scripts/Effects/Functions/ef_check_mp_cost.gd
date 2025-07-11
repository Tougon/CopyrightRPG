extends EffectFunction
class_name EFCheckMPCost

@export var target : EffectFunction.Target;
@export var check_mode : EffectFunction.CheckMode;
@export var mp_amount : int;


func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	var action = entity.current_action;
	
	if action != null:
		match check_mode :
			EffectFunction.CheckMode.EQUALS:
				if mp_amount == action.spell_cost:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.GREATER:
				if mp_amount < action.spell_cost:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.GREATEREQUAL:
				if mp_amount <= action.spell_cost:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.LESS:
				if mp_amount > action.spell_cost:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
			
			EffectFunction.CheckMode.LESSEQUAL:
				if mp_amount >= action.spell_cost:
					instance.cast_success = true;
				else:
					instance.cast_success = false;
