extends MenuPanel
class_name MenuMain


func _on_new_game_pressed() -> void:
	# Initialize save file
	DataManager.create_new_save();
	EventManager.load_scene.emit(DataManager.current_save.player_scene);


func _on_load_game_pressed() -> void:
	DataManager.load_data();
	
	if DataManager.current_save != null :
		SceneManager.set_position = true;
		SceneManager.use_target_player_position = true;
		SceneManager.target_player_position = DataManager.current_save.player_position;
		EventManager.load_scene.emit(DataManager.current_save.player_scene);
	else :
		print("Problems have occurred");
