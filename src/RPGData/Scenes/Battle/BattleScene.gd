extends Node2D
class_name BattleScene

@export var sequencer : Sequencer;
@export var dialogue_canvas : DialogueCanvas;
@export var seal_manager : SealManager
@export var enemy_positions : Node;
@export var begin_battle_on_ready : bool = true;

static var Instance : BattleScene;

var entities : Array[EntityController];
var players : Array[EntityController];
var enemies : Array[EntityController];

var turn_number : int;
var current_player_index : int;

var defeated_enemies : Array[DefeatedEntity];
var player_item_delta : Dictionary;


func _ready():
	Instance = self;
	
	EventManager.register_player.connect(_on_player_register);
	EventManager.register_enemy.connect(_on_enemy_register);
	EventManager.on_attack_select.connect(_on_attack_select);
	EventManager.on_magic_select.connect(_on_magic_select);
	EventManager.on_action_selected.connect(_on_action_selected);
	EventManager.on_defend_select.connect(_on_defend_select);
	EventManager.on_item_select.connect(_on_item_select);
	EventManager.player_menu_cancel.connect(_on_player_menu_cancel);
	EventManager.on_enemy_defeated.connect(_on_enemy_defeated);
	EventManager.on_player_item_consumed.connect(_on_player_item_consumed);
	
	if begin_battle_on_ready : begin_battle(null);


func begin_battle(params : BattleParams):
	var reference_height = get_window().size.y;
	get_window().size = Vector2i((reference_height * 4 / 3), reference_height);
	
	await get_tree().process_frame;
	
	entities = [];
	players = [];
	enemies = [];
	defeated_enemies = [];
	player_item_delta.clear();
	
	EventManager.on_battle_begin.emit(params);
	
	await get_tree().process_frame;
	
	# Initialize enemy positions
	var amt = enemies.size();
	var pos_root = enemy_positions.get_child(amt - 1);
	
	for i in amt:
		var enemy = enemies[i];
		enemy.set_enemy_position((pos_root.get_child((amt - 1) - i) as Node2D).position);
	
	# Fade in
	EventManager.battle_fade_start.emit(true);
	await EventManager.battle_fade_completed;
	
	# Print the opening dialogue
	EventManager.on_dialogue_queue.emit(_get_intro_dialogue());
	await EventManager.on_sequence_queue_empty;
	
	# Move the player controllers into view
	EventManager.set_player_group_state.emit(true);
	await get_tree().create_timer(0.5).timeout
	
	# Begin the turn
	_begin_turn();
	
	# Free the params from memory
	if params != null:
		params.destroy();
		params.free();


func _begin_turn():
	EventManager.on_turn_begin.emit();
	
	if sequencer.is_sequence_playing_or_queued() :
		await EventManager.on_sequence_queue_empty;
	
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
			if players[current_player_index].current_item != null:
				players[current_player_index].subtract_item(players[current_player_index].current_item);
			current_player_index += 1;
			
			if current_player_index < players.size() - 1:
				UIManager.close_menu_name("player_battle_target")
			
			if current_player_index < players.size():
				EventManager.set_active_player.emit(players[current_player_index]);
				await get_tree().process_frame;
				UIManager.open_menu_name("player_battle_main");
	
	# Perhaps you'll want to remove the dialogue here instead of awaiting?
	while dialogue_canvas.current_rows > 0:
		await get_tree().process_frame;
	
	for enemy in enemies:
		if enemy.is_defeated : continue;
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
		EventManager.on_entity_move.emit(entity);
		
		if entity.is_defeated:
			continue;
		
		var is_target_valid : bool = true;
		var num_active = get_num_active_enemies();
		
		# Multi target moves still work if at least one target still exists.
		for target in entity.current_target:
			if target.is_defeated:
				entity.current_target.erase(target);
		
		if entity.current_target.size() == 0:
			is_target_valid = false;
		
		# If possible, change target if attempted target is invalid
		if !is_target_valid:
			# Check to see if there are any targets left
			var alternate_targets = entity.get_possible_targets();
			
			# If no alternate targets exist, skip the turn.
			if alternate_targets.size() == 0 : continue;
			
			var target_type = entity.current_action.spell_target;
			
			match target_type:
				Spell.SpellTarget.SingleParty:
					entity.current_target.append(alternate_targets[0]);
				Spell.SpellTarget.SingleEnemy:
					entity.current_target.append(alternate_targets[0]);
				Spell.SpellTarget.RandomEnemy:
					entity.current_target.append(alternate_targets);
				Spell.SpellTarget.RandomEnemyPerHit:
					entity.current_target.append(alternate_targets);
		
		# Execute effects on move selected
		entity.execute_move_selected_effects();
		
		# Cast the spell
		var spell_cast = entity.current_action.cast(entity, entity.current_target);
		entity.action_result = spell_cast;
		
		var pre_anim_dialogue : Array[String];
		var post_anim_dialogue : Array[String];
		
		var any_cast_succeeded : bool = false;
		var play_animation : bool = true;
		
		for spell in spell_cast : 
			# Emergency check for item based actions
			if entity.current_item != null:
				var item = entity.current_item;
				
				# If item is no longer in the list through another action, fail the spell
				if !entity.item_list.has(item) || entity.item_list[item] <= 0:
					spell.success = false;
					play_animation = false;
					
					var item_fail_msg = _format_dialogue(tr("T_BATTLE_ACTION_ITEM_FAIL"), entity.param.entity_name, entity.current_entity);
					post_anim_dialogue.append(item_fail_msg);
			
			if spell.success : 
				any_cast_succeeded = true;
			else :
				if spell.fail_message != "" : post_anim_dialogue.append(spell.fail_message);
				if spell.fail_type == SpellCast.SpellFailType.InvalidMP : play_animation = false;
			
			for hit_result in spell.hit_results:
				if hit_result.length() > 0 && !post_anim_dialogue.has(hit_result):
					post_anim_dialogue.append(hit_result);
			
			# Get damage messages based on cast result
			if entity.current_action is DamageSpell && entity.current_action.spell_type != Spell.SpellType.Flavor && !BattleManager.async_damage_text : 
				if entity.current_action.spell_target == Spell.SpellTarget.RandomEnemyPerHit :
					_get_spell_hit_messages_rand(entity, spell_cast, spell, post_anim_dialogue);
				else :
					_get_spell_hit_messages(entity, spell_cast, spell, post_anim_dialogue);
		
		var cast_msg = _format_dialogue(tr(entity.current_action.spell_cast_message_key), entity.param.entity_name, entity.current_entity);
		
		# Format the cast message for targets
		if spell_cast.size() > 0:
			cast_msg = cast_msg.format({target = GrammarManager.get_plural_string(entity.current_target)})
		
		pre_anim_dialogue.append(cast_msg);
		
		for dialogue in pre_anim_dialogue:
			EventManager.on_dialogue_queue.emit(dialogue);
		
		if play_animation :
			var animation_seq = AnimationSequence.new(get_tree(), entity.current_action.animation_sequence, entity, entity.current_target, spell_cast);
			EventManager.on_sequence_queue.emit(animation_seq);
		
		for dialogue in post_anim_dialogue:
			EventManager.on_dialogue_queue.emit(dialogue);
		
		await EventManager.on_sequence_queue_empty;
		
		if entity.sealing:
			if seal_manager.can_seal_spell(entity.current_action):
				# Create the seal
				seal_manager.create_seal_instance(entity, entity.current_action, entity.seal_effect, players.has(entity))
				
				var seal_msg = _format_dialogue(tr("T_BATTLE_ACTION_SEAL_ACTIVE"), entity.param.entity_name, entity.current_entity);
				seal_msg = seal_msg.format({action = tr(entity.current_action.spell_name_key)});
				EventManager.on_dialogue_queue.emit(seal_msg);
				await EventManager.on_sequence_queue_empty;
			# TODO: Dialogue if seal failed
		
		# Reposition enemies if any have been defeated
		var amt = get_num_active_enemies();
		if num_active != amt:
			var index = 0;
			var pos_root = enemy_positions.get_child(amt - 1);
			var used : Array[int] = [];
			
			for i in range(enemies.size() - 1, -1, -1):
				var enemy = enemies[i];
				if !enemy.is_defeated:
					index = _get_closest_unused_root_to_entity(enemy, pos_root, used);
					
					if index != -1 :
						enemy.set_enemy_position((pos_root.get_child(index) as Node2D).position, BattleManager.ENEMY_REPOSITION_TIME);
						used.append(index);
			
			await get_tree().create_timer(BattleManager.ENEMY_REPOSITION_TIME).timeout
			await get_tree().process_frame;
		
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
			
			var luck = 1;
			# Originally included to prevent negative luck but...
			# we kind of want that, no?
			#if entity.param.entity_luck > 1:
			luck = entity.param.entity_luck;
			
			if e != null && proc <= effect.chance * luck:
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
		
		# Check if action is sealed
		seal_manager.check_for_seal(entity, players.has(entity));
		if sequencer.is_sequence_playing_or_queued() :
			await EventManager.on_sequence_queue_empty;
		
		for spell in spell_cast :
			spell.free();
		spell_cast.clear();
	
	_end_phase();


func _get_spell_hit_messages(entity : EntityController, spell_cast : Array[SpellCast], spell : SpellCast, output : Array[String]):
	var damage_spell = entity.current_action is DamageSpell;
	
	if spell.get_damage_applied() > 0 :
		if spell.critical && !BattleManager.async_crit_text: 
			if spell_cast.size() > 1 :
				output.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_SINGLE"), spell.target.param.entity_name, spell.target.current_entity));
			else : 
				output.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_GENERIC"), spell.target.param.entity_name, spell.target.current_entity));
		
		var damage_msg = _format_dialogue(tr("T_BATTLE_ACTION_DAMAGE"), spell.target.param.entity_name, spell.target.current_entity);
		damage_msg = damage_msg.format({damage = str(spell.get_damage_applied())});
		output.append(damage_msg);
	elif spell.get_damage_applied() == 0 && spell.effects.size() == 0:
		for hit in spell.hits:
			if hit :
				output.append(_format_dialogue(tr("T_BATTLE_ACTION_NO_DAMAGE_SINGLE"), spell.target.param.entity_name, spell.target.current_entity));
				return;


func _get_spell_hit_messages_rand(source : EntityController, spell_cast : Array[SpellCast], spell : SpellCast, output : Array[String]):
	var damage_spell = source.current_action is DamageSpell;
	var entities : Array[EntityController];
	var entity_damage = {}
	var entity_crit = {}
	var entity_miss = {};
	var entity_effects = {};
	
	for i in spell.get_number_of_hits():
		var entity_index = spell.target_index_override[i];
		var entity = source.current_target[entity_index];
		
		if !entities.has(entity):
			entities.append(entity);
			entity_damage[entity] = 0;
			entity_crit[entity] = false;
			entity_miss[entity] = true;
			entity_effects[entity] = 0;
		
		entity_damage[entity] += spell.damage[i];
		
		if spell.critical_hits[i] :
			entity_damage[entity] = true;
		if spell.hits[i] :
			entity_miss[entity] = false;
	
	for entity in entities :
		if entity_damage[entity] == 0 : 
			if entity_miss[entity] : continue;
			else : 
				output.append(_format_dialogue(tr("T_BATTLE_ACTION_NO_DAMAGE_SINGLE"), entity.param.entity_name, entity.current_entity));
				continue;
		
		if entity_crit[entity] && !BattleManager.async_crit_text: 
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
		entity.sealing = false;
		
		if !entity.is_defeated:
			# NOTE: In the original game, this is where we checked for remain active.
			# This will no longer be done to give more control over when this occurs.
			#entity.execute_remain_active_check();
			entity.execute_turn_end_effects();
	
	if sequencer.is_sequence_playing_or_queued() :
		await EventManager.on_sequence_queue_empty;
	EventManager.hide_entity_ui.emit();
	
	if (_all_players_defeated()) :
		# TODO: Do we even need this?
		EventManager.on_players_defeated.emit(); 
		
		var reward = BattleResult.new();
		reward.victory = false;
		
		EventManager.on_battle_completed.emit(reward); 
		return;
	else :
		if (_all_enemies_defeated()) :
			var reward = BattleResult.new();
			reward.victory = true;
			
			for enemy in defeated_enemies:
				reward.exp += enemy.entity.get_reward_exp(enemy.level);
				reward.enemies.append(enemy.entity.name_key)
			
			for player in players:
				var result_player = BattleParamEntity.new();
				result_player.override_entity = player.current_entity;
				result_player.override_level = player.level;
				result_player.id = (player as PlayerController).player_id;
				result_player.hp_offset = player.max_hp - player.current_hp;
				result_player.mp_offset = player.max_mp - player.current_mp
				result_player.should_award_exp = !player.is_defeated && player.level < BattleManager.level_cap;
				reward.players.append(result_player);
			
			reward.player_items = player_item_delta;
			
			EventManager.on_battle_completed.emit(reward); 
			return;
		_begin_turn();


# Support functions
func can_seal(spell : Spell) -> bool:
	for player in players:
		if player.sealing : return false;
	
	return seal_manager.can_seal_spell(spell);


func get_num_active_enemies() -> int:
	var result = 0;
	
	for enemy in enemies:
		if !enemy.is_defeated : result += 1;
	
	return result;


func _get_closest_unused_root_to_entity(enemy : EntityController, root : Node, used : Array[int]) -> int:
	var index = -1;
	var distance = 1000000000;
	
	for i in root.get_child_count():
		if used.has(i) : continue;
		
		var child = root.get_child(i) as Node2D;
		var d = enemy.global_position.distance_to(child.global_position);
		
		if d < distance:
			distance = d;
			index = i;
	
	return index;


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


func _on_action_selected(action : Spell, sealing : bool):
	players[current_player_index].current_action = action;
	players[current_player_index].sealing = sealing;
	
	if players[current_player_index].current_item != null :
		players[current_player_index].prev_action_type = PlayerController.ActionType.ITEM;
	else:
		players[current_player_index].prev_action_type = PlayerController.ActionType.SPELL;
	
	EventManager.initialize_target_menu.emit(players[current_player_index]);
	UIManager.open_menu_name("player_battle_target");


func _on_defend_select():
	players[current_player_index].current_action = players[current_player_index].defend_action;
	players[current_player_index].prev_action_type = PlayerController.ActionType.DEFEND;
	players[current_player_index].current_target = [ players[current_player_index] ];
	players[current_player_index].is_ready = true;


func _on_item_select():
	EventManager.initialize_item_menu.emit(players[current_player_index]);
	UIManager.open_menu_name("player_battle_item");


func _on_player_menu_cancel():
	if current_player_index > 0:
		current_player_index -= 1;
		players[current_player_index].is_ready = false;
		players[current_player_index].sealing = false;
		
		if players[current_player_index].current_item != null :
			players[current_player_index].add_item(players[current_player_index].current_item);
			players[current_player_index].current_item = null;
		
		EventManager.set_active_player.emit(players[current_player_index]);
		UIManager.open_menu_name("player_battle_main");


func _on_enemy_defeated(entity : EntityController):
	var defeated = DefeatedEntity.new();
	defeated.entity = entity.current_entity;
	defeated.level = entity.level;
	defeated_enemies.append(defeated);
	
	# Send the unused controller to the back of the list
	enemies.erase(entity);
	enemies.append(entity);
	
	var defeat_key = "T_BATTLE_DEFEAT_GENERIC";
	if entity.current_entity.battle_defeat_key != null :
		defeat_key = entity.current_entity.battle_defeat_key;
	
	var defeat_msg = _format_dialogue(tr(defeat_key), entity.param.entity_name, entity.current_entity);
	EventManager.on_dialogue_queue.emit(defeat_msg);


# Helper function for dialogue formatting
func _format_dialogue(dialogue : String, name : String, entity : Entity) -> String:
	var entity_name = name;
	
	if entity.generic : 
		return dialogue.format({article_indef = GrammarManager.get_indirect_article(entity_name), article_def = GrammarManager.get_direct_article(name), entity = name, pronoun1 = GrammarManager.get_pronoun(entity.gender, 1), pronoun2 = GrammarManager.get_pronoun(entity.gender, 2), pronoun3 = GrammarManager.get_pronoun(entity.gender, 3), pronoun4 = GrammarManager.get_pronoun(entity.gender, 4)});
	else:
		return dialogue.format({article_indef = "", article_def = "", entity = name, pronoun1 = GrammarManager.get_pronoun(entity.gender, 1), pronoun2 = GrammarManager.get_pronoun(entity.gender, 2), pronoun3 = GrammarManager.get_pronoun(entity.gender, 3), pronoun4 = GrammarManager.get_pronoun(entity.gender, 4)});


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


func _all_enemies_defeated() -> bool:
	for enemy in enemies:
		if !enemy.is_defeated : return false;
	
	return true;


func _compare_speed(a : EntityController, b : EntityController):
	return EntityController.compare_speed(a, b);


func _on_player_item_consumed(item : Item):
	var id = DataManager.item_database.get_id(item);
	if !player_item_delta.has(id):
		player_item_delta[id] = 0;
	
	player_item_delta[id] -= 1;


func _on_destroy():
	if EventManager != null:
		EventManager.register_player.disconnect(_on_player_register);
		EventManager.register_enemy.disconnect(_on_enemy_register);
		EventManager.on_attack_select.disconnect(_on_attack_select);
		EventManager.on_magic_select.disconnect(_on_magic_select);
		EventManager.on_action_selected.disconnect(_on_action_selected);
		EventManager.on_defend_select.disconnect(_on_defend_select);
		EventManager.on_item_select.disconnect(_on_item_select);
		EventManager.player_menu_cancel.disconnect(_on_player_menu_cancel);
		EventManager.on_enemy_defeated.disconnect(_on_enemy_defeated);
		EventManager.on_player_item_consumed.disconnect(_on_player_item_consumed);
	
	if Instance == self:
		Instance = null;
