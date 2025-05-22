extends Node

# The current active scene
var current_scene;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	print(current_scene.name);
	
	await get_tree().create_timer(10).timeout
	print("Begin Test Load")
	_load_scene("res://src/RPGData/Scenes/TestRoom_2.tscn");


# Loads the scene at the given path.
func _load_scene(path : String):
	# TODO: path validation (make sure scene is a path)
	if ResourceLoader.exists(path) :
		var loader = ResourceLoader.load_threaded_request(path)
		if loader == null:
			printerr("ERROR: loader is null. Something has gone terribly wrong.");
			return;
		
		var result = ResourceLoader.load_threaded_get_status(path);
		while result == ResourceLoader.THREAD_LOAD_IN_PROGRESS :
			await get_tree().process_frame;
			result = ResourceLoader.load_threaded_get_status(path);
		
		if result == ResourceLoader.THREAD_LOAD_LOADED :
			print("Loaded!")
			var new_scene = ResourceLoader.load_threaded_get(path);
			
			current_scene.queue_free();
			await get_tree().process_frame;
			var scene_inst = new_scene.instantiate();
			get_tree().root.add_child(scene_inst);
		else :
			print("Huh...");
		
	else :
		printerr("ERROR: " + path + " does not exist!");
