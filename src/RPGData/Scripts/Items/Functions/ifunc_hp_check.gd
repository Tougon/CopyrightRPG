extends ItemFunction

class_name IFuncHPCheck

@export var target : Target;
@export var check_mode : CheckMode;
@export_range(0, 1) var percent_amount : float = 0.5;
@export var use_amount : bool = false;
@export_range(0, 9999) var hp_amount : int = 0;

func execute_overworld(index : int, item : Item = null):
	if index < DataManager.party_data.size() && index >= 0:
		var current_state = DataManager.party_data[index];
		var entity_data = DataManager.entity_database.get_entity(current_state.id);
		
		var percent = (current_state.hp_value as float) / (entity_data.get_hp(current_state.level) as float);
		
		match check_mode :
			EffectFunction.CheckMode.EQUALS:
				if (use_amount && hp_amount == current_state.hp_value) || (!use_amount && percent_amount == percent):
					item.success = true;
				else:
					item.success = false;
			
			EffectFunction.CheckMode.GREATER:
				if (use_amount && hp_amount < current_state.hp_value) || (!use_amount && percent_amount < percent):
					item.success = true;
				else:
					item.success = false;
			
			EffectFunction.CheckMode.GREATEREQUAL:
				if (use_amount && hp_amount <= current_state.hp_value) || (!use_amount && percent_amount <= percent):
					item.success = true;
				else:
					item.success = false;
			
			EffectFunction.CheckMode.LESS:
				if (use_amount && hp_amount > current_state.hp_value) || (!use_amount && percent_amount > percent):
					item.success = true;
				else:
					item.success = false;
			
			EffectFunction.CheckMode.LESSEQUAL:
				if (use_amount && hp_amount >= current_state.hp_value) || (!use_amount && percent_amount >= percent):
					item.success = true;
				else:
					item.success = false;
	else:
		item.success = false;


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
