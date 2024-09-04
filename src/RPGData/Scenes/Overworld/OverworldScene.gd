extends Node2D

static var battle_scene : BattleScene = null;
static var battle_scene_window : Window = null;
@export var battle_scene_ref : PackedScene = preload("res://src/RPGData/Scenes/Battle/BattleScene.tscn");
@export var player_controller : RPGPlayerController;

# May as well be deprecated
var battle_scene_window_ref : PackedScene = preload("res://src/RPGData/Scenes/Battle/BattleSceneWindow.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.on_battle_queue.connect(_on_overworld_battle_queued);
	EventManager.on_battle_end.connect(_on_battle_end);
	
	OverworldManager.player_controller = player_controller;
	
	await get_tree().process_frame;
	
	if BattleManager.instance_battle_window :
		if battle_scene_ref != null && battle_scene == null: 
			battle_scene_window = battle_scene_window_ref.instantiate() as Window;
			self.add_child(battle_scene_window);
			battle_scene_window.visible = false;
			battle_scene = battle_scene_window.get_node("BattleScene") as BattleScene;
	else:
		if battle_scene_ref != null && battle_scene == null: 
			battle_scene = battle_scene_ref.instantiate() as BattleScene;
			battle_scene.begin_battle_on_ready = false;


func _on_overworld_battle_queued():
	# TODO: Remove
	DataManager.save_data();
	# TODO: Battle details as param
	EventManager.overworld_battle_fade_start.emit(false);
	await EventManager.overworld_battle_fade_completed;
	
	set_process(false);
	
	if BattleManager.instance_battle_window :
		battle_scene_window.visible = true;
		battle_scene.begin_battle();
	else:
		visible = false;
		get_tree().root.add_child(battle_scene);
		battle_scene.begin_battle();


func _on_battle_end():
	EventManager.overworld_battle_fade_start.emit(true);
	
	await get_tree().process_frame;
	
	if BattleManager.instance_battle_window :
			battle_scene_window.visible = false;
	else:
		get_tree().root.remove_child(battle_scene);
	
	set_process(true);
	visible = true;
	
	await EventManager.overworld_battle_fade_completed;
	
	EventManager.on_battle_dequeue.emit();


func _exit_tree():
	if EventManager != null:
		EventManager.on_battle_queue.disconnect(_on_overworld_battle_queued);
		EventManager.on_battle_end.disconnect(_on_battle_end);
