extends ItemFunction

class_name IFuncHeal

@export var target : Target;
@export_range(0, 9999) var heal_amt : int = 40;
@export var percent_heal : bool = false;
@export_range(0, 1) var percent_heal_amt : float = 0.5;
@export var negate : bool = false;

func execute_overworld(index : int, item : Item = null, preview : bool = false, result : ItemResult = null):
	var entity = DataManager.entity_database.get_entity(DataManager.party_data[index].id);
	var max_hp = entity.get_hp(DataManager.party_data[index].level);
	
	# Check equipment
	var current_weapon = DataManager.item_database.get_item(DataManager.party_data[index].weapon_id);
	var current_armor = DataManager.item_database.get_item(DataManager.party_data[index].armor_id);
	var current_accessory = DataManager.item_database.get_item(DataManager.party_data[index].accessory_id);
	var all_equipment = [current_weapon, current_armor, current_accessory];
	
	for e in all_equipment:
		if e != null:
			max_hp += (e as EquipmentItem).hp_mod;
	
	var amt = heal_amt;
	var before = DataManager.party_data[index].hp_value;
	
	if percent_heal : amt = roundi(float(max_hp) * percent_heal_amt);
	if negate : amt *= -1;
	
	var clamped = clamp(before + amt, 0, max_hp);
	
	if preview : 
		result.hp_mod = clamped;
		result.show_hp = true;
	else :
		DataManager.party_data[index].hp_value = clamped;
		EventManager.refresh_player_info.emit();


func execute_battle(user : EntityController, target : EntityController, item : Item = null):
	var entity : EntityController;
	if self.target == Target.USER: entity = user
	elif self.target == Target.TARGET: entity = target;
	
	if entity != null:
		var amt = heal_amt;
		var before = entity.current_hp;
		
		if percent_heal : amt = roundi(float(entity.max_hp) * percent_heal_amt);
		if !negate : amt *= -1;
		entity.apply_damage(amt, false, negate, negate);
		
		if entity.current_hp - before != 0:
			entity.update_hp_ui();
