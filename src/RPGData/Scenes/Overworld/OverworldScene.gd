extends Node2D

var current_battle : BattleScene = null;
@export var battle_scene : PackedScene = preload("res://src/RPGData/Scenes/Battle/BattleScene.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.on_battle_queue.connect(_on_overworld_battle_queued);
	EventManager.on_battle_end.connect(_on_battle_end);


func _on_overworld_battle_queued():
	# TODO: Battle details as param
	# TODO: Animation and crud (will vary based on details)
	visible = false;
	set_process(false);
	
	# Instantiate battle scene
	if battle_scene != null : 
		current_battle = battle_scene.instantiate() as BattleScene;
		get_tree().root.add_child(current_battle);
	else : print("Huh...")


func _on_battle_end():
	current_battle.queue_free();
	EventManager.on_battle_dequeue.emit();
	
	visible = true;
	set_process(true);


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_queue.disconnect(_on_overworld_battle_queued);
		EventManager.on_battle_end.disconnect(_on_battle_end);
