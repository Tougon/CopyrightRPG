extends Node2D

static var battle_scene : BattleScene = null;
@export var battle_scene_ref : PackedScene = preload("res://src/RPGData/Scenes/Battle/BattleScene.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.on_battle_queue.connect(_on_overworld_battle_queued);
	EventManager.on_battle_end.connect(_on_battle_end);
	
	await get_tree().process_frame;
	
	if battle_scene_ref != null && battle_scene == null: 
		battle_scene = battle_scene_ref.instantiate() as BattleScene;
		battle_scene.begin_battle_on_ready = false;


func _on_overworld_battle_queued():
	# TODO: Battle details as param
	EventManager.overworld_battle_fade_start.emit(false);
	await EventManager.overworld_battle_fade_completed;
	
	visible = false;
	set_process(false);
	
	get_tree().root.add_child(battle_scene);
	battle_scene.begin_battle();


func _on_battle_end():
	EventManager.overworld_battle_fade_start.emit(true);
	
	await get_tree().process_frame;
	get_tree().root.remove_child(battle_scene);
	
	set_process(true);
	visible = true;
	
	await EventManager.overworld_battle_fade_completed;
	
	EventManager.on_battle_dequeue.emit();


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_queue.disconnect(_on_overworld_battle_queued);
		EventManager.on_battle_end.disconnect(_on_battle_end);
