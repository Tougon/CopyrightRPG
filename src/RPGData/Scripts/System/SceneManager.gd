extends Node

# Amount of time to pause between a successful load and changing scenes.
const SCENE_LOAD_DELAY = 0.25;

# The current active scene
var current_scene;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_current_scene();
	EventManager.load_scene.connect(_load_scene);


# Initializes the current scene variable
func _init_current_scene():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)


# Loads the scene at the given path.
func _load_scene(path : String):
	# Load the resource if it exists
	if ResourceLoader.exists(path) :
		# Create loader
		var loader = ResourceLoader.load_threaded_request(path)
		if loader == null:
			printerr("ERROR: loader is null. Something has gone terribly wrong.");
			return;
		
		# TODO: Disable input
		# Fade out current scene
		EventManager.set_player_can_move.emit(false);
		EventManager.fade_bgm.emit(0, 1, true);
		EventManager.overworld_transition_fade_start.emit(false);
		await EventManager.overworld_transition_fade_completed;
		
		# If load is still in progress, wait
		var result = ResourceLoader.load_threaded_get_status(path);
		while result == ResourceLoader.THREAD_LOAD_IN_PROGRESS :
			await get_tree().process_frame;
			result = ResourceLoader.load_threaded_get_status(path);
		
		# If load completed, load the scene.
		if result == ResourceLoader.THREAD_LOAD_LOADED :
			# Add a bit of a delay for flavor
			await get_tree().create_timer(0.25).timeout
			
			# Get a reference to the scene object
			var new_scene = ResourceLoader.load_threaded_get(path);
			
			# Remove the current scene
			current_scene.queue_free();
			
			# Required to avoid issues with Phantom Camera
			await get_tree().process_frame;
			
			# Instantiate the new scene and transition in
			var scene_inst = new_scene.instantiate();
			get_tree().root.add_child(scene_inst);
			
			EventManager.set_player_can_move.emit(false);
			EventManager.overworld_transition_fade_start.emit(true);
			EventManager.fade_bgm.emit(1, 0, false);
			# TODO: Restore input
			await EventManager.overworld_transition_fade_completed;
			EventManager.set_player_can_move.emit(true);
			
			# Update the current scene reference
			current_scene = scene_inst;
			print(current_scene.name);
		
		else :
			printerr("ERROR: Scene failed to load!");
	
	# Otherwise throw error
	else :
		printerr("ERROR: " + path + " does not exist!");


func _exit_tree() :
	if EventManager != null :
		EventManager.load_scene.disconnect(_load_scene);
