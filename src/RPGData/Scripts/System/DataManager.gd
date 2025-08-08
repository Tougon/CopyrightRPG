extends Node

var current_save : SaveData;
var preferences : Preferences;
var party_data : Array[PartyMemberData]

var entity_database : EntityDatabase = preload("res://assets/Entities/entity_database.tres")
var quest_database : QuestDatabase = preload("res://assets/Quests/quest_database.tres")
var item_database : ItemDatabase = preload("res://assets/Items/item_database.tres")

signal on_data_loaded();
signal on_inventory_changed();


func _ready():
	current_save = SaveData.new();
	_load_preferences();
	
	# TODO: Don't do this automatically
	create_data();
	
	await get_tree().process_frame;


func create_data():
	party_data = [];
	
	if entity_database == null : print("Entity Database does not exist.");
	if quest_database == null : print("Quest Database does not exist.");
	if item_database == null : print("Item Database does not exist.");
	
	# Initialize Databases
	entity_database.initialize();
	item_database.initialize();
	
	# TODO: Better initialization for player?
	for i in GameplayConstants.MAX_PARTY_SIZE:
		var entity = DataManager.entity_database.get_entity(i, true)
		var move_list = entity.get_base_move_list();
		
		while move_list.size() < GameplayConstants.MAX_PLAYER_MOVE_LIST_SIZE:
			move_list.append(-1);
		
		var member = PartyMemberData.new();
		member.id = i;
		member.level = 5;
		member.exp = 0;
		member.unlocked = i <= 1;
		member.move_list = move_list;
		member.hp_value = entity.get_hp(member.level);
		if i == 0 : member.hp_value = 0;
		member.mp_value = entity.get_mp(member.level);
		party_data.append(member);
	
	# TODO: Remove this. This is temp item stuff.
	current_save.inventory[0] = 2;
	current_save.inventory[1] = 3;
	current_save.inventory[2] = 3;
	current_save.inventory[3] = 3;
	current_save.inventory[4] = 3;
	current_save.inventory[5] = 3;
	current_save.inventory[6] = 3;
	current_save.inventory[8] = 3;


func load_data():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	# TODO: Fail load if data is corrupt
	if save_file != null:
		var save = save_file.get_var(true);
		if save != null:
			current_save = save;
			
			# TODO: Add load(s) elsewhere. Probably with a loaded delegate
			OverworldManager.player_controller.position = current_save.player_position;
		else: print("Corrupt Save File")
		
		# Clear party data
		party_data = [];
		
		var party_size = save_file.get_var(true);
		
		for i in party_size:
			var member = save_file.get_var(true);
			
			if member != null:
				party_data.append(member);
			else : print("Corrupt Save File")
		
		var quest_data = save_file.get_var(true);
		
		if quest_data != null:
			QuestManager.load_saved_quest_data(quest_data);
		else : print("Corrupt Save File or Invalid Quest Data")
		
	else : print("No Save File")
	
	on_data_loaded.emit();


func save_data():
	# Update player position
	current_save.player_position = OverworldManager.player_controller.position;
	
	# Convert to binary and save
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	save_file.store_var(current_save, true);
	save_file.store_var(party_data.size(), true);
	
	for member in party_data:
		save_file.store_var(member, true);
	
	var quest_data = QuestManager.get_save_quest_data();
	save_file.store_var(quest_data, true);


func delete_data():
	DirAccess.remove_absolute("user://savegame.save");


func _load_preferences():
	var pref_file = FileAccess.open("user://preferences.save", FileAccess.READ);
	
	if pref_file != null :
		preferences = pref_file.get_var(true);
		if preferences == null : preferences = Preferences.new();
	else :
		preferences = Preferences.new();


func save_preferences():
	var save_file = FileAccess.open("user://preferences.save", FileAccess.WRITE)
	save_file.store_var(preferences, true);


# Item Functions

func get_battle_items() -> Dictionary:
	var result : Dictionary;
	
	for entry in item_database.entries :
		if current_save.inventory.has(entry.id) && current_save.inventory[entry.id] > 0:
			if entry.item is ConsumableItem && entry.item.use_battle : 
				result[entry.id] = current_save.inventory[entry.id];
	
	return result;


func get_move_items() -> Dictionary:
	var result : Dictionary;
	
	for entry in item_database.entries :
		if current_save.inventory.has(entry.id) && current_save.inventory[entry.id] > 0:
			if entry.item is MoveItem : 
				result[entry.id] = entry.item;
	
	return result;


func get_equipment_items(use_type : bool = false, equipment_equipment_type : EquipmentItem.EquipmentType = EquipmentItem.EquipmentType.Weapon) -> Dictionary:
	var result : Dictionary;
	
	for entry in item_database.entries :
		if current_save.inventory.has(entry.id) && current_save.inventory[entry.id] > 0:
			if entry.item is EquipmentItem : 
				if !use_type || (use_type && equipment_equipment_type == (entry.item as EquipmentItem).equipment_type) :
					result[entry.id] = entry.item;
	
	return result;


func change_item_amount(id : int, amount : int):
	if id < 0 : return;
	
	if amount > 0:
		if !current_save.inventory.has(id):
			current_save.inventory[id] = amount;
		else : current_save.inventory[id] += amount;
	else : 
		current_save.inventory[id] += amount;
		
		if current_save.inventory[id] <= 0:
			current_save.inventory.erase(id);
	
	# Refresh inventory callbacks
	on_inventory_changed.emit();


func get_item_amount(id : int) -> int:
	if current_save.inventory.has(id) : 
		return current_save.inventory[id];
	return 0;


func get_inventory_as_array() -> Array:
	var result : Array;
	
	for entry in item_database.entries :
		if current_save.inventory.has(entry.id) && current_save.inventory[entry.id] > 0:
			result.append(entry.id);
	
	return result;


# Misc

func _exit_tree() -> void:
	save_preferences();
