extends Node

var current_save : SaveData;
var party_data : Array[PartyMemberData]

var entity_database : EntityDatabase = preload("res://assets/Entities/entity_database.tres")
var quest_database : QuestDatabase = preload("res://assets/Quests/quest_database.tres")
var item_database : ItemDatabase = preload("res://assets/Items/item_database.tres")

signal on_data_loaded();


func _ready():
	current_save = SaveData.new();
	
	party_data = [];
	
	if entity_database == null : print("Entity Database does not exist.");
	if quest_database == null : print("Quest Database does not exist.");
	if item_database == null : print("Item Database does not exist.");
	
	for entry_id in entity_database.entries.size() :
		var entry = entity_database.entries[entry_id];
		
		if entry.entity_path != null :
			if ResourceLoader.exists(entry.entity_path, "Entity"):
				entry.entity = ResourceLoader.load(entry.entity_path, "Entity") as Entity;
			else:
				print("WARNING: Entity path at index " + str(entry_id) + " is invalid!");
	
	for item_id in item_database.entries.size() :
		var entry = item_database.entries[item_id];
		
		if entry.item_path != null :
			if ResourceLoader.exists(entry.item_path, "Item"):
				entry.item = ResourceLoader.load(entry.item_path, "Item") as Item;
			else:
				print("WARNING: Entity path at index " + str(item_id) + " is invalid!");
	
	# TODO: Better initialization for player
	for i in GameplayConstants.MAX_PARTY_SIZE:
		var member = PartyMemberData.new();
		member.id = i;
		member.level = 30;
		member.exp = 0;
		member.unlocked = i == 0;
		party_data.append(member);
	
	await get_tree().process_frame;


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
