extends Node2D

static var battle_scene : BattleScene = null;
static var battle_scene_window : Window = null;

@export_group("Gameplay Parameters")
@export var battle_scene_ref : PackedScene = preload("res://src/RPGData/Scenes/Battle/BattleScene.tscn");
@export var player_controller : RPGPlayerController;
@export var game_camera : PhantomCamera2D;
@export var free_camera : PhantomCamera2D;
@export var canvas_modulate : CanvasModulate;

@export_group("Cosmetic Parameters")
@export var bgm_id : String;

# Flooring
@onready var _area_root : Node = $Areas;
var _areas : Dictionary;
var _current_area : String;

var _current_floor_index : int = 0;
var _can_change_floor : bool = true;

var _faded_out_cutscene : bool = false;
var _bgm_time : float;
var _battle_start_timestamp : float;
var _battle_end_timestamp : float;

# May as well be deprecated
#var battle_scene_window_ref : PackedScene = preload("res://src/RPGData/Scenes/Battle/BattleSceneWindow.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.on_overworld_change_floor.connect(_on_overworld_change_floor);
	
	EventManager.on_battle_queue.connect(_on_overworld_battle_queued);
	EventManager.on_battle_end.connect(_on_battle_end);
	
	UIManager.on_menu_opened.connect(_on_menu_opened);
	UIManager.on_menu_closing.connect(_on_menu_closing);
	
	OverworldManager.player_controller = player_controller;
	OverworldManager.free_camera = free_camera;
	
	await get_tree().process_frame;
	
	_current_area = "atrium";
	_current_floor_index = DataManager.current_save.player_floor;
	
	if _area_root != null :
		var all_areas = _area_root.get_children();
		
		for area in all_areas:
			var area_data = area as OverworldArea;
			
			if area_data != null :
				area_data.visible = true;
				
				if !_areas.has(area_data.area_name_key):
					_areas[area_data.area_name_key] = area_data;
					
					if area_data.area_name_key == _current_area :
						area_data.set_area_active(true);
						area_data.set_floor_active(_current_floor_index, true);
						area_data.set_floor_visible(_current_floor_index, true, false);
						
						game_camera.set_follow_target(null);
						_areas[_current_area].put_player_on_floor(_current_floor_index, player_controller);
						_areas[_current_area].put_camera_on_floor(_current_floor_index, game_camera, free_camera);
						game_camera.set_follow_target(player_controller);
				else:
					area_data.set_area_active(false);
	
	# Not sure where BGM should be started
	# TODO: Revaluate this?
	play_bgm();
	
	if BattleManager.INSTANCE_BATTLE_WINDOW :
		if battle_scene_ref != null && battle_scene == null: 
			pass;
			#battle_scene_window = battle_scene_window_ref.instantiate() as Window;
			#self.add_child(battle_scene_window);
			#battle_scene_window.visible = false;
			#battle_scene = battle_scene_window.get_node("BattleScene") as BattleScene;
	else:
		if battle_scene_ref != null && battle_scene == null: 
			battle_scene = battle_scene_ref.instantiate() as BattleScene;
			battle_scene.begin_battle_on_ready = false;
	
	QuestManager.quest_completed.connect(quest_complete)
	Dialogic.timeline_started.connect(_on_dialogue_begin);
	Dialogic.timeline_ended.connect(_on_dialogue_end);
	
	EventManager.overworld_cutscene_fade_start.connect(_fade_action_cutscene);
	EventManager.overworld_cutscene_fade_instant.connect(_fade_action_cutscene_instant);


func _on_overworld_change_floor(new_floor : int, teleport : bool, pos : Vector2):
	if !_can_change_floor || new_floor == _current_floor_index || !_areas[_current_area].has_floor(new_floor): return;
	
	_can_change_floor = false;
	
	if teleport : 
		_overworld_player_teleport(pos);
	
	_areas[_current_area].set_floor_active(_current_floor_index, false);
	_areas[_current_area].set_floor_active(new_floor, true);
	
	if new_floor < _current_floor_index :
		_areas[_current_area].set_floor_visible(_current_floor_index, false);
	else :
		_areas[_current_area].set_floor_visible(new_floor, true);
	
	_current_floor_index = new_floor;
	
	#game_camera.set_follow_target(null);
	#player_controller.reparent(self);
	#game_camera.set_follow_target(player_controller);
	
	#await get_tree().create_timer(OverworldManager.FLOOR_TRANSITION_TIME).timeout
	
	game_camera.set_follow_target(null);
	_areas[_current_area].put_player_on_floor(_current_floor_index, player_controller);
	_areas[_current_area].put_camera_on_floor(_current_floor_index, game_camera, free_camera);
	game_camera.set_follow_target(player_controller);
	
	await get_tree().process_frame;
	_can_change_floor = true;
	#game_camera.set_follow_target(player_controller);


func _overworld_player_teleport(pos : Vector2):
	pos -= player_controller.foot_offset;
	var delta_pos = pos - player_controller.global_position;
	player_controller.global_position = pos;
	game_camera.teleport_position()


func _fade_action_cutscene(fade_in : bool):
	_faded_out_cutscene = !fade_in;


func _fade_action_cutscene_instant(fade_in : bool):
	_faded_out_cutscene = !fade_in;


func quest_complete(quest):
	print("REWARD MONEY: " + quest.quest_rewards.money);


func _on_dialogue_begin():
	pass;
	#if free_camera != null && game_camera != null :
		#free_camera.set_priority(2);
		#free_camera.position = game_camera.position;


func _on_dialogue_end():
	if free_camera != null :
		#free_camera.follow_target = null;
		free_camera.set_priority(0);
	
	if _faded_out_cutscene :
		player_controller._can_move = false;
		_faded_out_cutscene = false;
		EventManager.overworld_cutscene_fade_start.emit(true);
		await EventManager.overworld_cutscene_fade_completed;
		player_controller._can_move = true;


func _on_overworld_battle_queued(encounter : Encounter):
	BattleManager.is_battle_active = true;
	
	_bgm_time = AudioManager.get_bgm_time();
	_battle_start_timestamp = Time.get_unix_time_from_system();
	EventManager.fade_bgm.emit(0, 0, true);
	
	# TODO: Different fade animations based on encounter params
	EventManager.overworld_battle_fade_start.emit(false);
	await EventManager.overworld_battle_fade_completed;
	
	set_process(false);
	
	# Perpare battle parameters
	var params = BattleParams.new();
	
	# Initialize player data
	for i in GameplayConstants.MAX_PARTY_SIZE:
		if DataManager.party_data[i].unlocked:
			var player = BattleParamEntity.new();
			player.override_entity = DataManager.entity_database.get_entity(DataManager.party_data[i].id, true)
			player.override_level = DataManager.party_data[i].level;
			player.hp_offset = DataManager.party_data[i].hp_value;
			player.mp_offset = DataManager.party_data[i].mp_value;
			player.status = DataManager.party_data[i].status;
			
			player.override_weapon_id = DataManager.party_data[i].weapon_id;
			player.override_armor_id = DataManager.party_data[i].armor_id;
			player.override_accessory_id = DataManager.party_data[i].accessory_id;
			
			var moveset : Array[Spell];
			
			for move in DataManager.party_data[i].move_list:
				if move is String:
					var as_int = int(move);
					moveset.append(player.override_entity.move_list.list[as_int].spell);
				elif move is int && move != -1:
					var item = DataManager.item_database.get_item(move);
					if item != null && item is MoveItem:
						moveset.append((item as MoveItem).move);
			
			player.override_move_list = moveset;
			params.players.append(player);
		
		else : params.players.append(null);
	
	# Initialize enemy data
	for enemy_id in encounter.enemy_ids:
		var enemy = DataManager.entity_database.get_entity(enemy_id);
		
		if enemy != null:
			params.enemies.append(enemy);
	
	canvas_modulate.visible = false;
	if BattleManager.INSTANCE_BATTLE_WINDOW :
		battle_scene_window.visible = true;
		battle_scene.begin_battle(params);
	else:
		visible = false;
		get_tree().root.add_child(battle_scene);
		battle_scene.begin_battle(params);


func _on_battle_end(result : BattleResult):
	canvas_modulate.visible = true;
	
	# Process result
	# NOTE: For demo mode, we strip out any progression and item functions
	# This is for replayability.
	if !GameplayConstants.DEMO_MODE :
		for i in result.players.size():
			var player = result.players[i];
			DataManager.party_data[player.id].hp_value = player.hp_offset;
			DataManager.party_data[player.id].mp_value = player.mp_offset;
			DataManager.party_data[player.id].status = player.status;
			
			if player.should_award_exp :
				DataManager.party_data[player.id].level = player.override_level;
				DataManager.party_data[player.id].exp = player.modified_exp_amt;
		
		for id in result.player_items.keys() :
			DataManager.change_item_amount(id, result.player_items[id]);
		
		for id in QuestManager.player_quests:
			var metadata = QuestManager.get_meta_data(QuestManager.player_quests[id].quest_name);
			
			for data in metadata:
				# Check the quest metadata to see if it should progress based on battle result
				if data == "battle_auto":
					var step = QuestManager.player_quests[id].next_id
					QuestManager.progress_quest(id, step, "enemy", result.enemies.size())
					
					for enemy in result.enemies:
						QuestManager.progress_quest(id, step, enemy, 1)
	
	_battle_end_timestamp = Time.get_unix_time_from_system();
	var bgm_offset = _battle_end_timestamp - _battle_start_timestamp;
	play_bgm(0.75, true, _bgm_time + bgm_offset);
	
	EventManager.overworld_battle_fade_start.emit(true);
	
	await get_tree().process_frame;
	
	if BattleManager.INSTANCE_BATTLE_WINDOW :
		battle_scene_window.visible = false;
	else:
		get_tree().root.remove_child(battle_scene);
	
	set_process(true);
	visible = true;
	
	await EventManager.overworld_battle_fade_completed;
	
	EventManager.on_battle_dequeue.emit();
	BattleManager.is_battle_active = false;
	
	result.destroy();
	result.free();


func _on_menu_opened(menu : MenuPanel):
	if menu.menu_name == "overworld_menu_main":
		var tween = get_tree().create_tween();
		tween.tween_property(game_camera, "zoom", Vector2(1.2,1.2), 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


func _on_menu_closing(menu : MenuPanel):
	if menu.menu_name == "overworld_menu_main":
		var tween = get_tree().create_tween();
		tween.tween_property(game_camera, "zoom", Vector2(1.0,1.0), 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


# Audio Functions
func play_bgm(fade_time : float = 0, crossfade : bool = false, start_time : float = 0):
	EventManager.play_bgm.emit(bgm_id, fade_time, crossfade, start_time, 1);
	pass;


func _exit_tree():
	if player_controller != null :
		player_controller.clean_up();
	
	if EventManager != null:
		EventManager.on_overworld_change_floor.disconnect(_on_overworld_change_floor);
		
		EventManager.on_battle_queue.disconnect(_on_overworld_battle_queued);
		EventManager.on_battle_end.disconnect(_on_battle_end);
		
		EventManager.overworld_cutscene_fade_start.disconnect(_fade_action_cutscene);
		EventManager.overworld_cutscene_fade_instant.disconnect(_fade_action_cutscene_instant);
	
	if UIManager != null:
		UIManager.on_menu_opened.disconnect(_on_menu_opened);
		UIManager.on_menu_closing.disconnect(_on_menu_closing);
	
	QuestManager.quest_completed.disconnect(quest_complete)
	Dialogic.timeline_started.disconnect(_on_dialogue_begin);
	Dialogic.timeline_ended.disconnect(_on_dialogue_end);
