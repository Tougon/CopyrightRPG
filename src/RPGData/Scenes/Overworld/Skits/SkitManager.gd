extends Node

const MAX_SKIT_TIMER : float = 10.0;

var skit_database : SkitDatabase = preload("res://assets/Dialogue/Skits/SkitDatabase.tres")

var _skit_queue : Array;

var _dialogue_active : bool = false;
var _battle_active : bool = false;
var _current_skit_timer : float = 0.0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if skit_database == null :
		print("Skit Database does not exist.");
		return;
	
	EventManager.overworld_battle_fade_start.connect(_on_battle_state_changed);
	EventManager.on_overworld_player_moved.connect(_on_overworld_player_moved);
	EventManager.queue_skit.connect(_on_skit_queued);
	
	Dialogic.timeline_started.connect(_on_dialogue_begin);
	Dialogic.timeline_ended.connect(_on_dialogue_end);
	
	await get_tree().process_frame;
	
	_skit_queue = DataManager.current_save.skits_queued;
	
	_skit_loop();


func _skit_loop():
	if _dialogue_active || _battle_active || _skit_queue.size() == 0 :
		return; 
	
	if _current_skit_timer <= 0.0 :
		var skit_info = skit_database.get_skit_from_name(_skit_queue[0]);
		EventManager.show_skit_ui.emit(tr(skit_info.skit_name_key), true);
	
	await get_tree().process_frame;
	
	_current_skit_timer += get_process_delta_time();
	
	if _current_skit_timer >= MAX_SKIT_TIMER :
		print("DISABLE THIS SKIT FOREVER")
		var skit_info = skit_database.get_skit_from_name(_skit_queue[0]);
		EventManager.show_skit_ui.emit(tr(skit_info.skit_name_key), false);
		_disable_queued_skit();
		
		await get_tree().create_timer(3.0);
	
	_skit_loop();


func play_queued_skit():
	if _skit_queue.size() > 0 :
		print("PLAYING QUEUED SKIT");
		var skit_info = skit_database.get_skit_from_name(_skit_queue[0]);
		
		Dialogic.timeline_ended.connect(_on_skit_ended);
		EventManager.show_skit_ui.emit(tr(skit_info.skit_name_key), false);
		EventManager.on_skit_play.emit(tr(skit_info.skit_name_key), skit_info.skit_dialogue)
		
		DataManager.current_save.skits_seen.append(_skit_queue[0]);
		_skit_queue.remove_at(0);
		_current_skit_timer = 0.0;


func _on_skit_ended():
	Dialogic.timeline_ended.disconnect(_on_skit_ended);
	EventManager.on_skit_end.emit();


func _disable_queued_skit():
	if _skit_queue.size() > 0 :
		DataManager.current_save.skits_disabled.append(_skit_queue[0]);
		_skit_queue.remove_at(0);
		_current_skit_timer = 0.0;


func _on_battle_state_changed(inactive : bool):
	_battle_active = !inactive;
	
	if _battle_active :
		_disable_queued_skit();
	else :
		await EventManager.overworld_battle_fade_completed;
		await get_tree().create_timer(1.0);
		_skit_loop();


func _on_dialogue_begin():
	_dialogue_active = true;
	_disable_queued_skit();
	

func _on_dialogue_end():
	_dialogue_active = false;
	
	await get_tree().create_timer(1.0);
	_skit_loop();


func _on_overworld_player_moved(direction : Vector2, amount : Vector2, delta : float, run : bool, skid : bool):
	if skid : return;
	
	pass;


func _on_skit_queued(skit_name : String):
	var skit_info = skit_database.get_skit_from_name(skit_name);
	if skit_info == null : return;
	
	# Enqueue
	while _dialogue_active :
		await get_tree().process_frame;
	
	if DataManager.current_save.skits_disabled.has(skit_name) || _skit_queue.has(skit_name):
		return;
	
	_skit_queue.append(skit_name);
	_skit_loop();


func _exit_tree():
	Dialogic.timeline_started.connect(_on_dialogue_begin);
	Dialogic.timeline_ended.connect(_on_dialogue_end);
	
	if EventManager != null:
		EventManager.overworld_battle_fade_start.disconnect(_on_battle_state_changed);
		EventManager.on_overworld_player_moved.disconnect(_on_overworld_player_moved);
		EventManager.queue_skit.disconnect(_on_skit_queued);
