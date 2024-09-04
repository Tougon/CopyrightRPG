extends Node

var current_save : SaveData;

# Called when the node enters the scene tree for the first time.
func _ready():
	current_save = SaveData.new();
	await get_tree().process_frame;
	# TEMP: Auto loading data. 
	load_data();


func load_data():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	if save_file != null:
		var save = save_file.get_var(true);
		if save != null:
			current_save = save;
			
			# TODO: Add load(s) elsewhere. Where to though?
			OverworldManager.player_controller.position = current_save.player_position;
		else: print("Corrupt Save File")
	else : print("No Save File")


func save_data():
	# Update player position
	current_save.player_position = OverworldManager.player_controller.position;
	
	# Convert to binary and save
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_var(current_save, true);
