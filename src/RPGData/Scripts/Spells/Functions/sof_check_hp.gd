extends SpellOverworldFunction

class_name SOFuncCheckHP

@export var target : Target;
@export var check_mode : CheckMode;
@export_range(0, 1) var percent_amount : float = 0.5;
@export var use_amount : bool = false;
@export_range(0, 9999) var hp_amount : int = 0;

func execute(user : int, target : int, spell : Spell) -> bool:
	var index = user;
	if self.target == SpellOverworldFunction.Target.TARGET : index = target;
	
	if index < DataManager.party_data.size() && index >= 0:
		var current_state = DataManager.party_data[index];
		var entity_data = DataManager.entity_database.get_entity(current_state.id);
		
		var hp = entity_data.get_hp(current_state.level);
		
		# Check equipment
		var current_weapon = DataManager.item_database.get_item(current_state.weapon_id);
		var current_armor = DataManager.item_database.get_item(current_state.armor_id);
		var current_accessory = DataManager.item_database.get_item(current_state.accessory_id);
		var all_equipment = [current_weapon, current_armor, current_accessory];
		
		for e in all_equipment:
			if e != null:
				hp += (e as EquipmentItem).hp_mod;
		
		var percent = (current_state.hp_value as float) / (hp as float);
		
		match check_mode :
			EffectFunction.CheckMode.EQUALS:
				if (use_amount && hp_amount == current_state.hp_value) || (!use_amount && percent_amount == percent):
					return true;
				else:
					return false;
			
			EffectFunction.CheckMode.GREATER:
				if (use_amount && hp_amount < current_state.hp_value) || (!use_amount && percent_amount < percent):
					return true;
				else:
					return false;
			
			EffectFunction.CheckMode.GREATEREQUAL:
				if (use_amount && hp_amount <= current_state.hp_value) || (!use_amount && percent_amount <= percent):
					return true;
				else:
					return false;
			
			EffectFunction.CheckMode.LESS:
				if (use_amount && hp_amount > current_state.hp_value) || (!use_amount && percent_amount > percent):
					return true;
				else:
					return false;
			
			EffectFunction.CheckMode.LESSEQUAL:
				if (use_amount && hp_amount >= current_state.hp_value) || (!use_amount && percent_amount >= percent):
					return true
				else:
					return false;
		return false;
	else:
		return false;
