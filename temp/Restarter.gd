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
	
	# Scene removal code.
	EventManager.on_battle_end.emit();


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_completed.disconnect(_on_battle_complete);
