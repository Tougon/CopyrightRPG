extends Node

var current_save : SaveData;
var party_data : Array[PartyMemberData]

var entity_database : EntityDatabase = preload("res://assets/Entities/entity_database.tres")
var quest_database : QuestDatabase = preload("res://assets/Quests/quest_database.tres")


func _ready():
	current_save = SaveData.new();
	
	party_data = [];
	
	if entity_database == null : print("Entity Database does not exist.");
	if quest_database == null : print("Quest Database does not exist.");
	
	# TODO: Better initialization for player
	for i in GameplayConstants.MAX_PARTY_SIZE:
		var member = PartyMemberData.new();
		member.id = 0;
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
