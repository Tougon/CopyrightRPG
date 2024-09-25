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
	
	if BattleManager.INSTANCE_BATTLE_WINDOW :
		if battle_scene_ref != null && battle_scene == null: 
			battle_scene_window = battle_scene_window_ref.instantiate() as Window;
			self.add_child(battle_scene_window);
			battle_scene_window.visible = false;
			battle_scene = battle_scene_window.get_node("BattleScene") as BattleScene;
	else:
		if battle_scene_ref != null && battle_scene == null: 
			battle_scene = battle_scene_ref.instantiate() as BattleScene;
			battle_scene.begin_battle_on_ready = false;
	
	QuestManager.quest_completed.connect(quest_complete)

func quest_complete(quest):
	print(quest.quest_rewards.money)

func _on_overworld_battle_queued(encounter : Encounter):
	BattleManager.is_battle_active = true;
	
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
			player.hp_offset = DataManager.party_data[i].hp_dmg;
			player.mp_offset = DataManager.party_data[i].mp_dmg;
			params.players.append(player);
		else : params.players.append(null);
	
	# Initialize enemy data
	for enemy in encounter.enemies:
		params.enemies.append(enemy);
	
	if BattleManager.INSTANCE_BATTLE_WINDOW :
		battle_scene_window.visible = true;
		battle_scene.begin_battle(params);
	else:
		visible = false;
		get_tree().root.add_child(battle_scene);
		battle_scene.begin_battle(params);


func _on_battle_end(result : BattleResult):
	# Process result
	for i in result.players.size():
		var player = result.players[i];
		DataManager.party_data[player.id].hp_dmg = player.hp_offset;
		DataManager.party_data[player.id].mp_dmg = player.mp_offset;
		
		if player.should_award_exp :
			DataManager.party_data[player.id].level = player.override_level;
			DataManager.party_data[player.id].exp = player.modified_exp_amt;
	
	for id in QuestManager.player_quests:
		var metadata = QuestManager.get_meta_data(QuestManager.player_quests[id].quest_name);
		
		for data in metadata:
			# Check the quest metadata to see if it should progress based on battle result
			if data == "battle_auto":
				var step = QuestManager.player_quests[id].next_id
				QuestManager.progress_quest(id, step, "enemy", result.enemies.size())
				
				for enemy in result.enemies:
					QuestManager.progress_quest(id, step, enemy, 1)
	
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


func _exit_tree():
	if EventManager != null:
		EventManager.on_battle_queue.disconnect(_on_overworld_battle_queued);
		EventManager.on_battle_end.disconnect(_on_battle_end);
