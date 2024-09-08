extends Node

var current_save : SaveData;
var party_data : Array[PartyMemberData]

func _ready():
	current_save = SaveData.new();
	
	party_data = [];
	
	# TODO: Better initialization for player
	for i in 1:
		var member = PartyMemberData.new();
		member.id = "main";
		member.level = 1;
		member.exp = 0;
		party_data.append(member);
	
	await get_tree().process_frame;


func load_data():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	# TODO: Fail load if data is corrupt
	if save_file != null:
		var save = save_file.get_var(true);
		if save != null:
			current_save = save;
			
			# TODO: Add load(s) elsewhere. Where to though?
			OverworldManager.player_controller.position = current_save.player_position;
		else: print("Corrupt Save File")
		
		# Clear party data
		party_data = [];
		
		var party_size = save_file.get_var(true);
		print(party_size);
		for i in party_size:
			var member = save_file.get_var(true);
			
			if member != null:
				party_data.append(member);
				print(member.id);
			else : print("Corrupt Save File")
		
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


func delete_data():
	DirAccess.remove_absolute("user://savegame.save");
