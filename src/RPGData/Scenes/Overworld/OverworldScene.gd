extends Node2D

var battle_scene : BattleScene = null;
@export var battle_scene_ref : PackedScene = preload("res://src/RPGData/Scenes/Battle/BattleScene.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.on_battle_queue.connect(_on_overworld_battle_queued);
	EventManager.on_battle_end.connect(_on_battle_end);
	
	# TODO: Replace with global battle scene instead of having a battle scene per overworld
	await get_tree().process_frame;
	
	if battle_scene_ref != null : 
		battle_scene = battle_scene_ref.instantiate() as BattleScene;
		battle_scene.begin_battle_on_ready = false;


func _on_overworld_battle_queued():
	# TODO: Battle details as param
	# TODO: Animation and crud (will vary based on details)
	visible = false;
	set_process(false);
	
	get_tree().root.add_child(battle_scene);
	battle_scene.begin_battle();


func _on_battle_end():
	get_tree().root.remove_child(battle_scene);
	EventManager.on_battle_dequeue.emit();
	
	set_process(true);
	visible = true;


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_queue.disconnect(_on_overworld_battle_queued);
		EventManager.on_battle_end.disconnect(_on_battle_end);
