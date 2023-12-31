extends Node2D

@export var fade_sequence : TweenPlayer;
@export var sequencer : Sequencer;
@export var dialogue_canvas : DialogueCanvas;

var entities : Array[EntityController];
var players : Array[EntityController];
var enemies : Array[EntityController];

var current_player_index : int;


func _ready():
	EventManager.register_player.connect(_on_player_register);
	EventManager.register_enemy.connect(_on_enemy_register);
	EventManager.on_attack_select.connect(_on_attack_select);
	EventManager.player_menu_cancel.connect(_on_player_menu_cancel);
	_begin_battle();


func _begin_battle():
	
	await get_tree().process_frame;
	
	# Fade in
	if fade_sequence != null:
		fade_sequence.play_tween_name("Fade In");
		await fade_sequence.tween_ended;
	
	# Print the opening dialogue
	EventManager.on_dialogue_queue.emit(_get_intro_dialogue());
	await EventManager.on_sequence_queue_empty;
	
	# Begin the turn
	_begin_turn();


func _begin_turn():
	EventManager.on_turn_begin.emit();
	# TODO: Wait until all turn begin effects have resolved
	#await EventManager.on_sequence_queue_empty;
	current_player_index = 0;
	
	for player in players:
		player.allies.clear();
		player.allies.append_array(players);
		player.enemies.clear();
		player.enemies.append_array(enemies);
		player.turn_number += 1;
	
	for enemy in enemies:
		enemy.allies.clear();
		enemy.allies.append_array(enemies);
		enemy.enemies.clear();
		enemy.enemies.append_array(players);
		enemy.turn_number += 1;
	
	# Sort players/turn order by speed. Might cut this.
	# It was really annoying in OMORI to have the order be fixed,
	# Though I think that's moreso a problem with the game's UI design.
	players.sort_custom(_compare_speed);
	if players.size() > 0:
		EventManager.set_active_player.emit(players[current_player_index]);
	
	UIManager.open_menu_name("player_battle_main");
	
	_decision_phase();


# Name may be changed but this is the phase where we choose actions for the turn.
func _decision_phase():
	await get_tree().create_timer(1.5).timeout
	
	while current_player_index < players.size():
		await get_tree().process_frame;
		
		if players[current_player_index].is_ready:
			current_player_index += 1;
			UIManager.close_menu_name("player_battle_target")
			
			if current_player_index < players.size():
				EventManager.set_active_player.emit(players[current_player_index]);
				UIManager.open_menu_name("player_battle_main");
	
	# Perhaps you'll want to remove the dialogue here instead of awaiting?
	while dialogue_canvas.current_rows > 0:
		await get_tree().process_frame;
	
	# TODO: Process enemy actions for the turn
	for enemy in enemies:
		enemy.select_action();
		enemy.is_ready = true;
	
	_action_phase();


func _action_phase():
	# TODO: Execute turn start effects
	await get_tree().process_frame;
	
	var turn_order : Array[EntityController];
	
	for entity in entities:
		turn_order.append(entity);
	
	entities.sort_custom(_compare_speed);
	
	for entity in turn_order:
		# TODO: Handle seals (copyright)
		
		if entity.is_defeated:
			continue;
		
		var is_target_valid : bool = true;
		
		for target in entity.current_target:
			if target.is_defeated:
				is_target_valid = false;
		
		# TODO: Change target if target is invalid instead of skipping the turn
		if !is_target_valid:
			continue;
		
		# TODO: Execute effects on move selected
		
		# Cast the spell
		var spell_cast = entity.current_action.cast(entity, entity.current_target);
		entity.action_result = spell_cast;
		
		var pre_anim_dialogue : Array[String];
		var post_anim_dialogue : Array[String];
		
		var any_cast_succeeded : bool = false;
		
		for spell in spell_cast : 
			if spell.success : 
				any_cast_succeeded = true;
			
			# TODO: Increase damage taken
		
		var animation_seq = AnimationSequence.new(get_tree(), entity.current_action.animation_sequence, entity, entity.current_target, spell_cast);
		EventManager.on_sequence_queue.emit(animation_seq);
		
		await EventManager.on_sequence_queue_empty;
	
	_begin_turn();


# Event responses
func _on_player_register(entity : EntityController):
	entities.append(entity);
	players.append(entity);


func _on_enemy_register(entity : EntityController):
	entities.append(entity);
	enemies.append(entity);


func _on_attack_select():
	players[current_player_index].current_action = players[current_player_index].attack_action;
	UIManager.close_menu_name("player_battle_main");
	EventManager.initialize_target_menu.emit(players[current_player_index]);
	UIManager.open_menu_name("player_battle_target");


func _on_player_menu_cancel():
	if current_player_index > 0:
		current_player_index -= 1;
		players[current_player_index].is_ready = false;
		EventManager.set_active_player.emit(players[current_player_index]);
		UIManager.open_menu_name("player_battle_main");


# Helper function for dialogue formatting
func _format_dialogue(dialogue : String, name : String, entity : Entity) -> String:
	# TODO: Add pronoun support
	var entity_name = tr(entity.name_key)
	return dialogue.format({article_indef = GrammarManager.get_indirect_article(name), article_def = GrammarManager.get_direct_article(name), entity = name});


# Helper functions for intro dialogue
func _get_intro_dialogue() -> String:
	if enemies.size() == 0 :
		return "";
	
	var entity = enemies[0].current_entity;
	var name = enemies[0].param.entity_name;
	var key = entity.battle_intro_key;
	
	if enemies.size() > 1:
		if _all_enemies_same():
			key += "_PLURAL";
			name = enemies[0].param.entity_name_plural;
		else:
			key += "_GROUP";
	else:
		key += "_SINGLE";
	
	return _format_dialogue(tr(key), name, entity);


func _all_enemies_same() -> bool:
	if enemies.size() == 0 :
		return true;
	
	var entity = enemies[0].current_entity;
	for enemy in enemies:
		if enemy.current_entity != entity:
			return false;
	return true;


# Misc Functions
func _compare_speed(a : EntityController, b : EntityController):
	return EntityController.compare_speed(a, b);


func _on_destroy():
	if EventManager != null:
		EventManager.register_player.disconnect(_on_player_register);
		EventManager.register_enemy.disconnect(_on_enemy_register);
		EventManager.on_attack_select.disconnect(_on_attack_select);
		EventManager.player_menu_cancel.connect(_on_player_menu_cancel);
