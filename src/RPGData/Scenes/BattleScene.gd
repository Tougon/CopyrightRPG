extends Node2D

@export var fade_sequence : TweenPlayer;
@export var sequencer : Sequencer;


func _ready():
	_begin_battle();


func _begin_battle():
	
	await get_tree().process_frame;
	
	# Fade in
	if fade_sequence != null:
		fade_sequence.play_tween_name("Fade In");
		await fade_sequence.tween_ended;
	
	# Print the opening dialogue
	EventManager.on_dialogue_queue.emit("I see no hear no evil, black writing's on the wall")
	EventManager.on_dialogue_queue.emit("Unleashed a million faces, and one by one they fall")
	EventManager.on_dialogue_queue.emit("Black hearted evil")
	EventManager.on_dialogue_queue.emit("Brave hearted hero")
	EventManager.on_dialogue_queue.emit("I am all I am all I am")
	await EventManager.on_sequence_queue_empty;
	print("Working");
