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
	EventManager.on_magic_select.connect(_on_magic_select);
	EventManager.on_action_selected.connect(_on_action_selected);
	EventManager.on_defend_select.connect(_on_defend_select);
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
	
	# Timer to resolve fadeout issues with the glow
	UIManager.close_all_menus();
	await get_tree().create_timer(0.6).timeout
	_action_phase();


func _action_phase():
	# Execute turn start effects
	for entity in entities:
		entity.prev_action = entity.current_action;
		if !entity.is_defeated:
			entity.execute_turn_start_effects();
			
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
		
		# Execute effects on move selected
		entity.execute_move_selected_effects();
		
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
				if entity.current_action.spell_target == Spell.SpellTarget.RandomEnemyPerHit :
					_get_spell_hit_messages_rand(entity, spell_cast, spell, post_anim_dialogue);
				else :
					_get_spell_hit_messages(entity, spell_cast, spell, post_anim_dialogue);
		
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
		
		for spell in spell_cast:
			var effects = spell.effects;
			
			for effect in effects:
				if effect.cast_success : 
					effect.on_activate();
				else :
					effect.on_failed_to_activate();
		
		for effect in entity.current_action.effects_on_success:
			var e = effect.get_effect();
			var proc = randf();
			
			if e != null && proc <= effect.chance:
				var inst = e.create_effect_instance(entity, entity, null);
				inst.check_success();
				
				if inst.cast_success && any_cast_succeeded: 
					inst.on_activate();
				else :
					inst.on_failed_to_activate();
		
		entity.execute_move_completed_effects();
		
		if sequencer.is_sequence_playing_or_queued() :
			await EventManager.on_sequence_queue_empty;
		EventManager.hide_entity_ui.emit();
		
		for spell in spell_cast :
			spell.free();
		spell_cast.clear();
	
	_end_phase();


func _get_spell_hit_messages(entity : EntityController, spell_cast : Array[SpellCast], spell : SpellCast, output : Array[String]):
	var damage_spell = entity.current_action is DamageSpell;
	
	if spell.get_damage_applied() > 0 :
		if spell.critical : 
			if spell_cast.size() > 1 :
				output.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_SINGLE"), spell.target.param.entity_name, spell.target.current_entity));
			else : 
				output.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_GENERIC"), spell.target.param.entity_name, spell.target.current_entity));
		
		var damage_msg = _format_dialogue(tr("T_BATTLE_ACTION_DAMAGE"), spell.target.param.entity_name, spell.target.current_entity);
		damage_msg = damage_msg.format({damage = str(spell.get_damage_applied())});
		output.append(damage_msg);


func _get_spell_hit_messages_rand(source : EntityController, spell_cast : Array[SpellCast], spell : SpellCast, output : Array[String]):
	var damage_spell = source.current_action is DamageSpell;
	var entities : Array[EntityController];
	var entity_damage = {}
	var entity_crit = {}
	
	for i in spell.get_number_of_hits():
		var entity_index = spell.target_index_override[i];
		var entity = source.current_target[entity_index];
		
		if !entities.has(entity):
			entities.append(entity);
			entity_damage[entity] = 0;
			entity_crit[entity] = false;
		
		entity_damage[entity] += spell.damage[i];
		
		if spell.critical_hits[i] :
			entity_damage[entity] = true;
	
	for entity in entities :
		if entity_damage[entity] <= 0 : continue;
		
		if entity_crit[entity] : 
			if spell_cast.size() > 1 :
				output.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_SINGLE"), entity.param.entity_name, entity.current_entity));
			else : 
				output.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_GENERIC"), entity.param.entity_name, entity.current_entity));
		
		var damage_msg = _format_dialogue(tr("T_BATTLE_ACTION_DAMAGE"), entity.param.entity_name, entity.current_entity);
		damage_msg = damage_msg.format({damage = str(entity_damage[entity])});
		output.append(damage_msg);


func _end_phase():
	# Execute turn end effect functions
	for entity in entities:
		if !entity.is_defeated:
			# NOTE: In the original game, this is where we checked for remain active.
			# This will no longer be done to give more control over when this occurs.
			#entity.execute_remain_active_check();
			entity.execute_turn_end_effects();
	
	if sequencer.is_sequence_playing_or_queued() :
		await EventManager.on_sequence_queue_empty;
	EventManager.hide_entity_ui.emit();
	
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
	players[current_player_index].prev_action_type = PlayerController.ActionType.ATTACK;
	EventManager.initialize_target_menu.emit(players[current_player_index]);
	UIManager.open_menu_name("player_battle_target");


func _on_magic_select():
	EventManager.initialize_magic_menu.emit(players[current_player_index]);
	UIManager.open_menu_name("player_battle_magic");


func _on_action_selected(action : Spell):
	players[current_player_index].current_action = action;
	players[current_player_index].prev_action_type = PlayerController.ActionType.SPELL;
	EventManager.initialize_target_menu.emit(players[current_player_index]);
	UIManager.open_menu_name("player_battle_target");


func _on_defend_select():
	players[current_player_index].current_action = players[current_player_index].defend_action;
	players[current_player_index].prev_action_type = PlayerController.ActionType.DEFEND;
	players[current_player_index].current_target = [ players[current_player_index] ];
	players[current_player_index].is_ready = true;


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
		EventManager.on_magic_select.disconnect(_on_magic_select);
		EventManager.on_action_selected.disconnect(_on_action_selected);
		EventManager.on_defend_select.disconnect(_on_defend_select);
		EventManager.player_menu_cancel.disconnect(_on_player_menu_cancel);
		EventManager.on_enemy_defeated.disconnect(_on_enemy_defeated);
