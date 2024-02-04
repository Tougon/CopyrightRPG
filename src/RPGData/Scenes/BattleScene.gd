extends Node2D

@export var fade_sequence : TweenPlayer;
@export var sequencer : Sequencer;
@export var dialogue_canvas : DialogueCanvas;

var entities : Array[EntityController];
var players : Array[EntityController];
var enemies : Array[EntityController];

var turn_number : int;
var current_player_index : int;


func _ready():
	EventManager.register_player.connect(_on_player_register);
	EventManager.register_enemy.connect(_on_enemy_register);
	EventManager.on_attack_select.connect(_on_attack_select);
	EventManager.player_menu_cancel.connect(_on_player_menu_cancel);
	EventManager.on_enemy_defeated.connect(_on_enemy_defeated);
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
	turn_number += 1;
	
	var allies : Array[EntityController];
	var targets : Array[EntityController];
	
	for entity in entities:
		entity.allies.clear();
		entity.enemies.clear();
		entity.turn_number += 1;
		entity.is_ready = false;
		entity.reset_action();
		
		if !entity.is_defeated :
			if players.has(entity) : allies.append(entity);
			if enemies.has(entity) : targets.append(entity);
	
	for player in players:
		player.allies.append_array(allies);
		player.enemies.append_array(targets);
	
	for enemy in enemies:
		enemy.allies.append_array(targets);
		enemy.enemies.append_array(allies);
	
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
	# For what purpose, Evan? For what purpose?
	#await get_tree().create_timer(1.5).timeout
	
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
		if !entity.is_defeated :
			turn_order.append(entity);
	
	turn_order.sort_custom(_compare_speed);
	
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
			
			# TODO: Additional info
			# Get damage messages based on cast result
			if entity.current_action is DamageSpell : 
				var damage_spell = entity.current_action is DamageSpell;
				
				if spell.get_damage_applied() > 0 :
					if spell.critical : 
						if spell_cast.size() > 1 :
							post_anim_dialogue.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_SINGLE"), spell.target.param.entity_name, spell.target.current_entity));
						else : 
							post_anim_dialogue.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_GENERIC"), spell.target.param.entity_name, spell.target.current_entity));
					
					var damage_msg = _format_dialogue(tr("T_BATTLE_ACTION_DAMAGE"), spell.target.param.entity_name, spell.target.current_entity);
					damage_msg = damage_msg.format({damage = str(spell.get_damage_applied())});
					post_anim_dialogue.append(damage_msg);
		
		var cast_msg = _format_dialogue(tr(entity.current_action.spell_cast_message_key), entity.param.entity_name, entity.current_entity);
		
		# TODO: do additional formatting for target name perhaps?
		pre_anim_dialogue.append(cast_msg);
		
		for dialogue in pre_anim_dialogue:
			EventManager.on_dialogue_queue.emit(dialogue);
		
		var animation_seq = AnimationSequence.new(get_tree(), entity.current_action.animation_sequence, entity, entity.current_target, spell_cast);
		EventManager.on_sequence_queue.emit(animation_seq);
		
		# TODO: Evaluate if we want the death animation before or after dialogue.
		#await EventManager.on_sequence_queue_empty;
		
		for dialogue in post_anim_dialogue:
			EventManager.on_dialogue_queue.emit(dialogue);
		
		await EventManager.on_sequence_queue_empty;
		
		EventManager.hide_entity_ui.emit();
	
	_end_phase();


func _end_phase():
	# TODO: Turn end behaviors for effects
	
	# TODO: Proper lose state
	if (_all_players_defeated()) : return;
	else :
		# TODO: Check win state
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


func _on_enemy_defeated(entity : EntityController):
	var defeat_key = "T_BATTLE_INTRO_GENERIC";
	if entity.current_entity.battle_intro_key != null :
		defeat_key = entity.current_entity.battle_defeat_key;
	
	var defeat_msg = _format_dialogue(tr(defeat_key), entity.param.entity_name, entity.current_entity);
	EventManager.on_dialogue_queue.emit(defeat_msg);


# Helper function for dialogue formatting
func _format_dialogue(dialogue : String, name : String, entity : Entity) -> String:
	# TODO: Add pronoun support
	var entity_name = name;
	
	if entity.generic : 
		return dialogue.format({article_indef = GrammarManager.get_indirect_article(entity_name), article_def = GrammarManager.get_direct_article(name), entity = name});
	else:
		return dialogue.format({article_indef = "", article_def = "", entity = name});


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
func _all_players_defeated() -> bool:
	for player in players:
		if !player.is_defeated : return false;
	
	return true;


func _compare_speed(a : EntityController, b : EntityController):
	return EntityController.compare_speed(a, b);


func _on_destroy():
	if EventManager != null:
		EventManager.register_player.disconnect(_on_player_register);
		EventManager.register_enemy.disconnect(_on_enemy_register);
		EventManager.on_attack_select.disconnect(_on_attack_select);
		EventManager.player_menu_cancel.disconnect(_on_player_menu_cancel);
		EventManager.on_enemy_defeated.disconnect(_on_enemy_defeated);
