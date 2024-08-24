extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.on_battle_completed.connect(_on_battle_complete);


func _on_battle_complete(victory : bool):
	if victory:
		EventManager.on_dialogue_queue.emit("You earned 50 EXP (Not that it matters).");
	else:
		EventManager.on_dialogue_queue.emit("The party fades to nothing...");
	
	await EventManager.on_sequence_queue_empty;
	
	# Fade Out
	EventManager.battle_fade_start.emit(false);
	await EventManager.battle_fade_completed;
	
	get_tree().reload_current_scene();
	
	# Scene removal code.
	# Will be required when we additively open the battle scenes
	#var root = get_tree().get_root()
	#var current_scene = root.get_child(root.get_child_count() - 1)
	#current_scene.queue_free()


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_completed.disconnect(_on_battle_complete);
