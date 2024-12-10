extends ItemFunction

class_name IFuncHPCheck

@export var target : Target;
@export var check_mode : CheckMode;
@export_range(0, 1) var percent_amount : float = 0.5;
@export var use_amount : bool = false;
@export_range(0, 9999) var hp_amount : int = 0;

func execute_overworld(target : int):
	pass;

func execute_battle(user : EntityController, target : EntityController, item : Item = null):
	var entity : EntityController;
	if self.target == Target.USER: entity = user
	elif self.target == Target.TARGET: entity = target;
	
	if entity != null:
		match check_mode :
			EffectFunction.CheckMode.EQUALS:
				if (use_amount && hp_amount == entity.current_hp) || (!use_amount && percent_amount == entity.get_hp_percent()):
					item.success = true;
				else:
					item.success = false;
			
			EffectFunction.CheckMode.GREATER:
				if (use_amount && hp_amount < entity.current_hp) || (!use_amount && percent_amount < entity.get_hp_percent()):
					item.success = true;
				else:
					item.success = false;
			
			EffectFunction.CheckMode.GREATEREQUAL:
				if (use_amount && hp_amount <= entity.current_hp) || (!use_amount && percent_amount <= entity.get_hp_percent()):
					item.success = true;
				else:
					item.success = false;
			
			EffectFunction.CheckMode.LESS:
				if (use_amount && hp_amount > entity.current_hp) || (!use_amount && percent_amount > entity.get_hp_percent()):
					item.success = true;
				else:
					item.success = false;
			
			EffectFunction.CheckMode.LESSEQUAL:
				if (use_amount && hp_amount >= entity.current_hp) || (!use_amount && percent_amount >= entity.get_hp_percent()):
					item.success = true;
				else:
					item.success = false;
	else : item.success = false;
