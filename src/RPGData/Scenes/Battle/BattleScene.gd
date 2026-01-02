extends Node2D
class_name BattleScene

@export var sequencer : Sequencer;
@export var dialogue_canvas : DialogueCanvas;
@export var seal_manager : SealManager
@export var enemy_positions : Node;
@export var begin_battle_on_ready : bool = true;
@export var persistent_effects : Array[Effect];

static var Instance : BattleScene;

var entities : Array[EntityController];
var players : Array[EntityController];
var enemies : Array[EntityController];

var enemy_type_count : Dictionary;

var turn_number : int;
var current_player_index : int;

var defeated_enemies : Array[DefeatedEntity];
var player_item_delta : Dictionary;

var _default_entity : Entity;

var _field_effects : Array[FieldEffectInstance];

var _reserve_enemies : Array[Entity];
var _reserve_controllers : Array[EntityController];
var _spawning = false;

# Fleeing values
var _panic_battle : bool = false;
var _can_flee : bool = true;
var _can_flee_this_turn : bool = true;

# Result caching
var _reward_items : Array[Item];
var _learned_moves : Dictionary;

# Enemy modifiers
var _current_num_entities : int = 1;

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
	EventManager.on_player_defeated.connect(_on_player_defeated);
	EventManager.on_enemy_defeated.connect(_on_enemy_defeated);
	EventManager.on_player_item_consumed.connect(_on_player_item_consumed);
	EventManager.add_entity_to_battle.connect(_add_entity_to_battle);
	EventManager.learn_move_from_seal.connect(_learn_move_from_seal);
	
	if begin_battle_on_ready : begin_battle(null);


func begin_battle(params : BattleParams):
	_reserve_controllers.clear();
	_reward_items.clear();
	
	var reference_height = get_window().size.y;
	get_window().size = Vector2i((reference_height * 4 / 3), reference_height);
	
	await get_tree().process_frame;
	
	entities = [];
	players = [];
	enemies = [];
	defeated_enemies = [];
	enemy_type_count.clear();
	player_item_delta.clear();
	
	_can_flee = params.can_flee;
	
	for i in range(BattleManager.MAX_ENEMY_COUNT, params.enemies.size()):
		_reserve_enemies.append(params.enemies[i]);
	
	_current_num_entities = min(BattleManager.MAX_ENEMY_COUNT, params.enemies.size());
	
	_default_entity = params.enemies[0];
	
	_panic_battle = params.panic_battle;
	
	EventManager.on_battle_begin.emit(params);
	
	if _panic_battle :
		AudioManager.play_bgm("full_throttle", 0, true, 0, 1);
	
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
	EventManager.on_dialogue_queue.emit(_get_intro_dialogue(enemies));
	if _panic_battle : EventManager.on_dialogue_queue.emit(tr("T_BATTLE_FLEE_NO"));
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
	
	current_player_index = _get_lowest_valid_player_index();
	turn_number += 1;
	
	var allies : Array[EntityController];
	var targets : Array[EntityController];
	
	var speed_enemy : int;
	var speed_player : int;
	
	for entity in entities:
		entity.allies.clear();
		entity.enemies.clear();
		entity.turn_number += 1;
		entity.is_ready = false;
		entity.reset_action();
		entity.turn_seed = randf();
		
		if players.has(entity) : allies.append(entity);
		if enemies.has(entity) : targets.append(entity);
	
	for player in players:
		player.allies.append_array(allies);
		player.enemies.append_array(targets);
		if player.is_defeated : player.is_ready = true;
		else : 
			if player.param.entity_spd > speed_player : 
				speed_player = player.param.entity_spd
	
	for enemy in enemies:
		enemy.allies.append_array(targets);
		enemy.enemies.append_array(allies);
		
		if enemy.param.entity_spd > speed_enemy : 
			speed_enemy = enemy.param.entity_spd;
	
	var _flee_chance = (speed_player as float) / ((speed_enemy * 2) as float)
	_flee_chance *= turn_number;
	_can_flee_this_turn = randf() < _flee_chance;
	
	# Sort players/turn order by speed. Might cut this.
	# It was really annoying in OMORI to have the order be fixed,
	# Though I think that's moreso a problem with the game's UI design.
	players.sort_custom(_compare_speed);
	if players.size() > 0:
		EventManager.set_active_player.emit(players[current_player_index], _is_lowest_valid_player());
		EventManager.set_player_bg.emit(players[current_player_index].current_entity);
	
	UIManager.open_menu_name("player_battle_main");
	
	_decision_phase();


# Name may be changed but this is the phase where we choose actions for the turn.
func _decision_phase():
	# For what purpose, Evan? For what purpose?
	#await get_tree().create_timer(1.5).timeout
	
	while current_player_index < players.size() && current_player_index >= 0:
		
		await get_tree().process_frame;
		
		if players[current_player_index].is_ready || players[current_player_index].skip_decision:
			if players[current_player_index].current_item != null:
				players[current_player_index].subtract_item(players[current_player_index].current_item);
			current_player_index = _get_next_valid_player_index(current_player_index + 1);
			
			if current_player_index < players.size() - 1:
				UIManager.close_menu_name("player_battle_target")
			
			if current_player_index < players.size():
				EventManager.set_active_player.emit(players[current_player_index], _is_lowest_valid_player());
				EventManager.set_player_bg.emit(players[current_player_index].current_entity);
				await get_tree().process_frame;
				UIManager.open_menu_name("player_battle_main");
	
	if current_player_index == -1 : return;
	
	# Perhaps you'll want to remove the dialogue here instead of awaiting?
	while dialogue_canvas.current_rows > 0:
		await get_tree().process_frame;
	
	# Enemies always select their actions in order without the sort
	# This means that E1 always takes priority regarding Seals
	enemies.sort_custom(_compare_speed);
	
	for enemy in enemies:
		if enemy.is_defeated : continue;
		if !enemy.skip_decision : enemy.select_action();
		enemy.is_ready = true;
	
	# Timer to resolve fadeout issues with the glow
	UIManager.close_all_menus();
	await get_tree().create_timer(0.6).timeout
	_action_phase();


func _action_phase():
	EventManager.set_player_bg.emit(_default_entity);
	var turn_order : Array[EntityController];
	
	for entity in entities:
		entity.action_replaced = false;
		
		if !entity.is_defeated :
			turn_order.append(entity);
	
	turn_order.sort_custom(_compare_speed);
	
	# Process all turn start events and seals
	for entity in turn_order :
		entity.intended_action = entity.current_action;
		entity.intended_target = entity.current_target.duplicate();
		
		if !entity.is_defeated:
			entity.execute_turn_start_effects();
		
		if sequencer.is_sequence_playing_or_queued() :
			await EventManager.on_sequence_queue_empty;
		
		if entity.sealing && BattleManager.seal_before_attacking:
			if seal_manager.can_seal_spell(entity.current_action, entity):
				# Create the seal
				seal_manager.create_seal_instance(entity, entity.current_action, entity.seal_effect, players.has(entity))
				
				var seal_msg = format_dialogue(tr("T_BATTLE_ACTION_SEAL_ACTIVE"), entity.param.entity_name, entity.current_entity);
				seal_msg = seal_msg.format({action = tr(entity.current_action.spell_name_key)});
				EventManager.on_dialogue_queue.emit(seal_msg);
				await EventManager.on_sequence_queue_empty;
			# TODO: Dialogue if seal failed
	
	await get_tree().process_frame;
	
	while turn_order.size() > 0:
		var entity = turn_order[0]
		EventManager.on_entity_move.emit(entity);
		
		if entity.is_defeated || _all_players_defeated() || _all_enemies_defeated():
			turn_order.remove_at(0);
			continue;
		
		if entity.current_action == null :
			EventManager.on_entity_turn_end.emit(entity);
			turn_order.remove_at(0);
			continue;
		
		if !(_all_players_defeated() || _all_enemies_defeated()) :
			EventManager.hide_entity_ui.emit();
			entity.mat.set_shader_parameter("overlay_color", Color.WHITE)
			# Looks bad on players for now but this is a sprite issue
			entity.tween.play_tween_name("Entity Ready Up");
			
			if entity is PlayerController : AudioManager.play_sfx("player_act");
			else : AudioManager.play_sfx("enemy_act");
			
			await get_tree().create_timer(0.2).timeout
			await get_tree().process_frame;
			
			#EventManager.set_player_bg.emit(entity);
		
		var is_target_valid : bool = true;
		var num_active = get_num_active_enemies();
		
		# Multi target moves still work if at least one target still exists.
		var target_index = 0;
		while target_index < entity.current_target.size():
			var target = entity.current_target[target_index];
			
			if (target.is_defeated && !entity.current_action.target_defeated_entities) || (!target.is_defeated && entity.current_action.target_defeated_entities):
				entity.current_target.erase(target);
			else : target_index += 1;
		
		if entity.current_target.size() == 0:
			is_target_valid = false;
		
		# If possible, change target if attempted target is invalid
		if !is_target_valid:
			# Check to see if there are any targets left
			var alternate_targets = entity.get_possible_targets();
			
			# If no alternate targets exist, skip the turn.
			if alternate_targets.size() == 0 : 
				turn_order.remove_at(0);
				continue;
			
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
			
			# If the target is invalid, change intended target
			entity.intended_target = entity.current_target.duplicate();
		
		# Execute effects on move selected
		entity.execute_move_selected_effects();
		
		# Await sequences if any have been called from On Move 
		if sequencer.is_sequence_playing_or_queued() :
			await EventManager.on_sequence_queue_empty;
		
		# Cast the spell
		var spell_cast = entity.current_action.cast(entity, entity.current_target);
		entity.action_result = spell_cast;
		
		var flags : Array[TFlag] = [];
		
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
					
					var item_fail_msg = format_dialogue(tr("T_BATTLE_ACTION_ITEM_FAIL_NONE"), entity.param.entity_name, entity.current_entity);
					post_anim_dialogue.append(item_fail_msg);
				# If item cannot be used, don't use it
				elif !entity.can_use_item(item):
					spell.success = false;
					play_animation = false;
					
					var item_fail_msg = format_dialogue(tr("T_BATTLE_ACTION_FAIL"), entity.param.entity_name, entity.current_entity);
					post_anim_dialogue.append(item_fail_msg);
			
			for flag in spell.spell_flags :
				if !flags.has(flag) :
					flags.append(flag);
			
			if spell.success : 
				any_cast_succeeded = true;
			else :
				#if spell.fail_message != "" : post_anim_dialogue.append(spell.fail_message);
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
		
		if !any_cast_succeeded :
			for spell in spell_cast :
				if spell.fail_message != "" :
					post_anim_dialogue.append(spell.fail_message);
		
		var cast_msg = format_dialogue(tr(entity.current_action.spell_cast_message_key), entity.param.entity_name, entity.current_entity);
		# Format the cast message for targets
		if spell_cast.size() > 0:
			var target_name = GrammarManager.get_plural_string(entity.current_target);
			target_name = "[color=FFFF00]" + target_name + "[/color]";
			cast_msg = cast_msg.format({target = target_name})
		
		pre_anim_dialogue.append(cast_msg);
		
		for dialogue in pre_anim_dialogue:
			EventManager.on_dialogue_queue.emit(dialogue);
		
		if play_animation :
			var animation_seq = AnimationSequence.new(get_tree(), entity.current_action.animation_sequence, entity, entity.current_target, spell_cast);
			EventManager.on_sequence_queue.emit(animation_seq);
		
		await EventManager.on_sequence_queue_empty;
		
		# Check to catch any missing dialogue that may have been appended from the sequence
		for spell in spell_cast : 
			if spell.subspell_casts != null :
				for subspell in spell.subspell_casts :
					if subspell.success : 
						any_cast_succeeded = true;
			
			for hit_result in spell.hit_results:
				if hit_result.length() > 0 && !post_anim_dialogue.has(hit_result):
					post_anim_dialogue.append(hit_result);
		
		for dialogue in post_anim_dialogue:
			EventManager.on_dialogue_queue.emit(dialogue);
		
		if post_anim_dialogue.size() > 0 : await EventManager.on_sequence_queue_empty;
		
		# Add reserve enemies if applicable
		var spawned_entities : Array[EntityController];
		for i in _reserve_controllers.size() :
			if _reserve_enemies.size() == 0 :
				break;
			
			var new_enemy = _reserve_enemies[0];
			_reserve_enemies.remove_at(0);
			
			var enemy_controller = _reserve_controllers[0];
			spawned_entities.append(enemy_controller);
			_reserve_controllers.remove_at(0);
			
			while enemy_controller.is_defeat_anim_playing():
				await get_tree().process_frame;
			
			# Reset the entity
			enemy_controller.prev_action = null;
			enemy_controller.current_action = null;
			enemy_controller.current_target.clear();
			enemy_controller.current_entity = new_enemy;
			enemy_controller.entity_init(null);
			_adjust_enemy_name(enemy_controller);
			
			enemy_controller.play_appear_animation();
		
		while is_any_entity_appearing(spawned_entities) :
			await get_tree().process_frame;
		
		if spawned_entities.size() > 0:
			var enemy_spawn_msg = _get_intro_dialogue(spawned_entities);
			EventManager.on_dialogue_queue.emit(enemy_spawn_msg);
			await EventManager.on_sequence_queue_empty;
		
		# Reposition enemies if necessary
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
			
			num_active = amt;
			
			await get_tree().create_timer(BattleManager.ENEMY_REPOSITION_TIME).timeout
			await get_tree().process_frame;
		
		if amt > 0 :
			for spell in spell_cast:
				if _all_players_defeated() : 
					continue;
				var effects = spell.effects;
				
				for effect in effects:
					if effect.cast_success : 
						effect.on_activate();
					else :
						effect.on_failed_to_activate();
					
					if !effect.applied : 
						effect.free();
		
			for effect in entity.current_action.effects_on_success:
				if _all_players_defeated() : continue;
				var e = effect.get_effect();
				var proc = randf();
				
				var luck = 1;
				# Originally included to prevent negative luck but...
				# we kind of want that, no?
				#if entity.param.entity_luck > 1:
				if effect.use_luck :
					luck = entity.param.entity_luck;
				
				if e != null && proc <= effect.chance * luck:
					var inst = e.create_effect_instance(entity, entity, null);
					inst.all_casts = spell_cast;
					inst.check_success();
					
					if inst.cast_success && any_cast_succeeded: 
						inst.on_activate();
					else :
						inst.on_failed_to_activate();
					
					if !inst.applied : 
						inst.free();
			
			entity.execute_move_completed_effects();
		
		while _spawning:
			await get_tree().process_frame;
		
		if sequencer.is_sequence_playing_or_queued() :
			await EventManager.on_sequence_queue_empty;
		EventManager.hide_entity_ui.emit();
		
		if entity.sealing && !BattleManager.seal_before_attacking && !_all_players_defeated():
			if seal_manager.can_seal_spell(entity.current_action, entity) && entity.seal_effect != null:
				# Create the seal
				seal_manager.create_seal_instance(entity, entity.current_action, entity.seal_effect, players.has(entity))
				
				var seal_msg = format_dialogue(tr("T_BATTLE_ACTION_SEAL_ACTIVE"), entity.param.entity_name, entity.current_entity);
				
				var action_name = "";
				
				if entity.current_action.spell_name_key.is_empty() || (BattleManager.ENEMY_SEAL_FORCE_GENERIC_NAME && entity is EnemyController):
					action_name = tr("T_SPELL_GENERIC_PRONOUN");
					action_name = action_name.format({ pronoun3 = GrammarManager.get_pronoun(entity.param.entity_gender, 3) })
				else :
					action_name = tr(entity.current_action.spell_name_key);
				
				seal_msg = seal_msg.format({ action = action_name });
				EventManager.on_dialogue_queue.emit(seal_msg);
				await EventManager.on_sequence_queue_empty;
			# TODO: Dialogue if seal failed
		
		# Check if action is sealed
		if !_all_players_defeated():
			seal_manager.check_for_seal(entity, players.has(entity), flags);
		if sequencer.is_sequence_playing_or_queued() :
			await EventManager.on_sequence_queue_empty;
		
		# Don't process normal end turn calls if the battle has ended
		if !(_all_players_defeated() || _all_enemies_defeated()) :
			EventManager.on_entity_turn_end.emit(entity);
		
		# Required in case any entity has been defeated from an effect
		if !_spawning :
			# Reposition enemies if necessary
			amt = get_num_active_enemies();
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
		
		# IMPORTANT: We need this, but any cast tied to an effect should stay
		for spell in spell_cast :
			if spell.subspell_casts != null :
				for subspell in spell.subspell_casts:
					subspell.free();
			spell.free();
		spell_cast.clear();
		
		turn_order.remove_at(0);
		turn_order.sort_custom(_compare_speed);
	
	await get_tree().process_frame;
	_end_phase();


func _get_spell_hit_messages(entity : EntityController, spell_cast : Array[SpellCast], spell : SpellCast, output : Array[String]):
	if spell.target.is_defeated || spell.target.current_hp - spell.get_damage_applied() <= 0: return;
	
	var damage_spell = entity.current_action is DamageSpell;
	
	if spell.get_damage_applied() > 0 :
		if spell.critical && !BattleManager.async_crit_text: 
			if spell_cast.size() > 1 :
				output.append(format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_SINGLE"), spell.target.param.entity_name, spell.target.current_entity));
			else : 
				output.append(format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_GENERIC"), spell.target.param.entity_name, spell.target.current_entity));
		
		var damage_msg = "";
		
		if spell.spell is DamageSpell && (spell.spell as DamageSpell).negate :
			damage_msg = format_dialogue(tr("T_BATTLE_ACTION_HEAL"), spell.target.param.entity_name, spell.target.current_entity);
		else :
			damage_msg = format_dialogue(tr("T_BATTLE_ACTION_DAMAGE"), spell.target.param.entity_name, spell.target.current_entity);
		damage_msg = damage_msg.format({damage = str(spell.get_damage_applied())});
		output.append(damage_msg);
	elif spell.get_damage_applied() == 0 && spell.effects.size() == 0:
		for hit in spell.hits:
			if hit :
				if spell.spell is DamageSpell && (spell.spell as DamageSpell).negate :
					output.append(format_dialogue(tr("T_BATTLE_ACTION_NO_HEAL_SINGLE"), spell.target.param.entity_name, spell.target.current_entity));
				else :
					output.append(format_dialogue(tr("T_BATTLE_ACTION_NO_DAMAGE_SINGLE"), spell.target.param.entity_name, spell.target.current_entity));


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
			entity_crit[entity] = true;
		if spell.hits[i] :
			entity_miss[entity] = false;
	
	for entity in entities :
		if entity_damage[entity] == 0 : 
			if entity_miss[entity] : continue;
			else : 
				output.append(format_dialogue(tr("T_BATTLE_ACTION_NO_DAMAGE_SINGLE"), entity.param.entity_name, entity.current_entity));
				continue;
		
		if entity_crit[entity] && !BattleManager.async_crit_text: 
			if spell_cast.size() > 1 :
				output.append(format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_SINGLE"), entity.param.entity_name, entity.current_entity));
			else : 
				output.append(format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_GENERIC"), entity.param.entity_name, entity.current_entity));
		
		if entity.current_hp - entity_damage[entity] <= 0: continue;
		var damage_msg = format_dialogue(tr("T_BATTLE_ACTION_DAMAGE"), entity.param.entity_name, entity.current_entity);
		damage_msg = damage_msg.format({damage = str(entity_damage[entity])});
		output.append(damage_msg);


func _learn_move_from_seal(learning_entity : EntityController, move : Spell):
	var player = learning_entity as PlayerController;
	if player == null : return;
	
	if !_learned_moves.has(player.player_id) :
		_learned_moves[player.player_id] = [];
	
	var move_item = DataManager.item_database.get_item_from_move(move);
	
	if move_item != null :
		if !_reward_items.has(move_item) :
			_reward_items.append(move_item);
	
		var move_id = DataManager.item_database.get_id(move_item);
		
		if !_learned_moves[player.player_id].has(move_id) && !DataManager.party_data[player.player_id].move_learned.has(move_id):
			_learned_moves[player.player_id].append(move_id);
			
			var dialogue = tr("T_BATTLE_LEARN");
			dialogue = dialogue.format({ article_def = GrammarManager.get_direct_article(learning_entity.param.entity_name), entity = learning_entity.param.entity_name, spell = tr(move.spell_name_key) });
			EventManager.on_dialogue_queue.emit(dialogue);


func _end_phase():
	# Execute turn end effect functions
	for entity in entities : 
		if enemies.has(entity) :
			if entity.intended_action != null && entity.intended_action.will_save_as_prev :
				entity.prev_action = entity.intended_action;
		else :
				entity.prev_action = entity.intended_action;
		
		entity.prev_target = entity.intended_target.duplicate();
	
	# If at least one player is currently alive, check for a victory
	if (!_all_players_defeated()) :
		if (_all_enemies_defeated()) :
			var reward = BattleResult.new();
			reward.victory = true;
			reward.fled = false;
			
			for enemy in defeated_enemies:
				reward.exp += enemy.entity.get_reward_exp(enemy.level);
				reward.enemies.append(enemy.entity.name_key)
				enemy.free();
			defeated_enemies.clear();
			
			for player in players:
				var result_player = BattleParamEntity.new();
				result_player.override_entity = player.current_entity;
				result_player.override_level = player.level;
				result_player.id = (player as PlayerController).player_id;
				result_player.hp_offset = player.current_hp;
				result_player.mp_offset = player.current_mp
				result_player.should_award_exp = !player.is_defeated && player.level < BattleManager.level_cap;
				
				if _learned_moves.has(result_player.id) :
					for move in _learned_moves[result_player.id] :
						result_player.learned_moves.append(move);
				
				reward.players.append(result_player);
				
				for effect in persistent_effects :
					if player.has_effect(effect.effect_name) :
						result_player.status.append(effect.effect_name);
			
			reward.player_items = player_item_delta;
			
			for item in _reward_items :
				var id = DataManager.item_database.get_id(item);
				
				if id != -1 :
					reward.reward_items[id] = 1;
			
			EventManager.on_battle_completed.emit(reward); 
			return;
	
	# If the battle is not over, apply effects
	
	var to_remove : Array[FieldEffect] = [];
	for field_effect in _field_effects:
		field_effect.turns_active += 1;
		
		if field_effect.effect.turn_limit >= 0 && field_effect.turns_active >= field_effect.effect.turn_limit :
			to_remove.append(field_effect.effect);
	
	for field_effect in to_remove :
		remove_field_effect(field_effect);
	
	for entity in entities:
		if !entity.skip_decision:
			entity.sealing = false;
		
		if !entity.is_defeated:
			# NOTE: In the original game, this is where we checked for remain active.
			# This will no longer be done to give more control over when this occurs.
			#entity.execute_remain_active_check();
			entity.execute_turn_end_effects();
	
	if sequencer.is_sequence_playing_or_queued() :
		await EventManager.on_sequence_queue_empty;
	EventManager.hide_entity_ui.emit();
	
	# Check to see if the effects have caused a loss state
	if _all_players_defeated() :
		# TODO: Do we even need this?
		EventManager.on_players_defeated.emit(); 
		
		var reward = BattleResult.new();
		reward.victory = false;
		reward.fled = false;
		
		EventManager.on_battle_completed.emit(reward); 
		return;
	else :
		if _all_enemies_defeated() : 
			_end_phase();
		else : _begin_turn();


# Effect functions
func apply_field_effect(field_effect : FieldEffect) :
	if field_effect != null :
		var inst = _get_instance_from_field_effect(field_effect);
		if inst != null : 
			if field_effect.stackable : 
				inst.turns_active = 0;
				field_effect.stack(players, enemies);
			else :
				var fail_msg = format_dialogue(tr("T_BATTLE_ACTION_FAIL"), "", null);
				EventManager.on_dialogue_queue.emit(fail_msg);
		else :
			_field_effects.append(field_effect.create_instance())
			field_effect.activate(players, enemies);


func _get_instance_from_field_effect(field_effect : FieldEffect) -> FieldEffectInstance:
	for effect in _field_effects:
		if effect.effect == field_effect : return effect;
	
	return null;


func remove_field_effect(field_effect : FieldEffect) :
	if field_effect != null :
		var inst = _get_instance_from_field_effect(field_effect);
		field_effect.deactivate(players, enemies);
		_field_effects.erase(inst);
		inst.free();


# Support functions
func can_seal(spell : Spell) -> bool:
	for player in players:
		if player.sealing : return false;
	
	return seal_manager.can_seal_spell(spell, null);


func get_num_active_players(invert : bool = false) -> int:
	var result = 0;
	
	for player in players:
		if !player.is_defeated && !invert : result += 1;
		if player.is_defeated && invert : result += 1;
	
	return result;


func get_num_active_enemies(invert : bool = false) -> int:
	var result = 0;
	
	for enemy in enemies:
		if !enemy.is_defeated && !invert : result += 1;
		if enemy.is_defeated && invert : result += 1;
	
	return result;


func is_any_entity_appearing(entities_to_check : Array[EntityController]) -> bool :
	for e in entities_to_check :
		if e.is_appear_anim_playing() : 
			return true;
	
	return false;


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
func _on_entity_register(entity : EntityController):
	for field_effect in _field_effects:
		if entity is PlayerController : 
			field_effect.effect.activate([entity], []);
		else : 
			field_effect.effect.activate([], [entity]);


func _on_player_register(entity : EntityController):
	_on_entity_register(entity);
	entities.append(entity);
	players.append(entity);
	
	_load_entity_audio(entity);


func _on_enemy_register(entity : EntityController):
	if entity.param == null : 
		_reserve_controllers.append(entity);
		return;
	
	if enemies.size() == 0 && !_panic_battle: 
		EventManager.play_bgm.emit(entity.current_entity.entity_bgm_key, 0, true, 0, 1);
	
	_adjust_enemy_name(entity);
	
	_on_entity_register(entity);
	entities.append(entity);
	enemies.append(entity);
	
	_load_entity_audio(entity);
	
	print("BEFORE MOD: " + str(entity.param.entity_atk));
	print("BEFORE MOD: " + str(entity.param.entity_def));
	print("BEFORE MOD: " + str(entity.param.entity_sp_atk));
	print("BEFORE MOD: " + str(entity.param.entity_sp_def));
	
	for i in _current_num_entities - 1 :
		entity.max_hp /= BattleManager.ENEMY_STAT_DIVISOR;
		entity.param.entity_atk /= BattleManager.ENEMY_STAT_DIVISOR;
		entity.param.entity_def /= BattleManager.ENEMY_STAT_DIVISOR;
		entity.param.entity_sp_atk /= BattleManager.ENEMY_STAT_DIVISOR;
		entity.param.entity_sp_def /= BattleManager.ENEMY_STAT_DIVISOR;
	
	entity.param.entity_hp = entity.max_hp;
	
	print("AFTER MOD: " + str(entity.param.entity_atk));
	print("AFTER MOD: " + str(entity.param.entity_def));
	print("AFTER MOD: " + str(entity.param.entity_sp_atk));
	print("AFTER MOD: " + str(entity.param.entity_sp_def));


func _adjust_enemy_name(entity : EntityController):
	# TODO: ABC's instead of 123's
	if enemy_type_count.has(entity.current_entity):
		# Rename first entity of the same type
		if enemy_type_count[entity.current_entity] == 1:
			for enemy in enemies:
				if enemy.current_entity == entity.current_entity:
					enemy.param.entity_name += " " + str(enemy_type_count[entity.current_entity]);
					enemy.param.entity_name_short += " " + str(enemy_type_count[entity.current_entity]);
					enemy.param.renamed = true;
		
		enemy_type_count[entity.current_entity] += 1;
		entity.param.entity_name += " " + str(enemy_type_count[entity.current_entity]);
		entity.param.entity_name_short += " " + str(enemy_type_count[entity.current_entity]);
		entity.param.renamed = true;
	else :
		enemy_type_count[entity.current_entity] = 1;


func _load_entity_audio(entity : EntityController):
	if entity is PlayerController:
		EventManager.load_aux_audio.emit(entity.attack_action.spell_sfx);
		EventManager.load_aux_audio.emit(entity.defend_action.spell_sfx);
	
	for move in entity.move_list:
		EventManager.load_aux_audio.emit(move.spell_sfx);


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


func _on_player_menu_cancel(cancel_button : bool):
	if !_is_lowest_valid_player():
		current_player_index = _get_prev_valid_player_index(current_player_index);
		players[current_player_index].is_ready = false;
		players[current_player_index].sealing = false;
		
		if players[current_player_index].current_item != null :
			players[current_player_index].add_item(players[current_player_index].current_item);
			players[current_player_index].current_item = null;
		
		EventManager.set_active_player.emit(players[current_player_index], _is_lowest_valid_player());
		EventManager.set_player_bg.emit(players[current_player_index].current_entity);
		UIManager.open_menu_name("player_battle_main");
		
		AudioManager.play_sfx("battle_menu_cancel", 0.1);
	# Only execute flee operations if the button was pressed
	elif !cancel_button :
		if _can_flee:
			if _can_flee_this_turn : 
				current_player_index = -1;
				UIManager.close_menu_name("player_battle_main");
				
				var reward = BattleResult.new();
				reward.victory = false;
				reward.fled = true;
				
				for enemy in enemies :
					# Should never realistically occur but w/e
					if !enemy.is_defeated :
						reward.remaining_enemies.append(DataManager.entity_database.get_id(enemy.current_entity))
				
				EventManager.on_battle_completed.emit(reward); 
			else :
				UIManager.close_menu_name("player_battle_main");
				EventManager.on_dialogue_queue.emit(tr("T_BATTLE_FLEE_FAIL"));
				await EventManager.on_sequence_queue_empty;
				UIManager.open_menu_name("player_battle_main");
		else : 
			UIManager.close_menu_name("player_battle_main");
			EventManager.on_dialogue_queue.emit(tr("T_BATTLE_FLEE_NO"));
			await EventManager.on_sequence_queue_empty;
			UIManager.open_menu_name("player_battle_main");


func _on_player_defeated(entity : EntityController):
	var defeat_key = "T_BATTLE_DEFEAT_PLAYER";
	var defeat_msg = format_dialogue(tr(defeat_key), entity.param.entity_name, entity.current_entity);
	EventManager.on_dialogue_queue.emit(defeat_msg);


func _on_enemy_defeated(entity : EntityController):
	var defeated = DefeatedEntity.new();
	defeated.entity = entity.current_entity;
	defeated.level = entity.level;
	defeated_enemies.append(defeated);
	
	# Send the unused controller to the back of the list
	enemies.erase(entity);
	enemies.append(entity);
	_current_num_entities -= 1;
	
	_reserve_controllers.append(entity);
	
	var defeat_key = "T_BATTLE_DEFEAT_GENERIC";
	if entity.current_entity.battle_defeat_key != null :
		defeat_key = entity.current_entity.battle_defeat_key;
	
	var defeat_msg = format_dialogue(tr(defeat_key), entity.param.entity_name, entity.current_entity);
	EventManager.on_dialogue_queue.emit(defeat_msg);


# Helper function for dialogue formatting
func format_dialogue(dialogue : String, name : String, entity : Entity, target_name : String = "", target : Entity = null) -> String:
	var entity_name = name;
	# Testing color formatting
	name = "[color=FFFF00]" + name + "[/color]";
	
	var result : String = "";
	
	if entity.generic && (enemy_type_count.has(entity) && enemy_type_count[entity] <= 1): 
		result = dialogue.format({article_indef = GrammarManager.get_indirect_article(entity_name), article_def = GrammarManager.get_direct_article(entity_name), entity = name, pronoun1 = GrammarManager.get_pronoun(entity.gender, 1), pronoun2 = GrammarManager.get_pronoun(entity.gender, 2), pronoun3 = GrammarManager.get_pronoun(entity.gender, 3), pronoun4 = GrammarManager.get_pronoun(entity.gender, 4)});
	else:
		result = dialogue.format({article_indef = "", article_def = "", entity = name, pronoun1 = GrammarManager.get_pronoun(entity.gender, 1), pronoun2 = GrammarManager.get_pronoun(entity.gender, 2), pronoun3 = GrammarManager.get_pronoun(entity.gender, 3), pronoun4 = GrammarManager.get_pronoun(entity.gender, 4)});
	
	if target != null :
		entity_name = target_name;
		target_name = "[color=FFFF00]" + target_name + "[/color]";
		
		if target.generic && (enemy_type_count.has(target) && enemy_type_count[target] <= 1): 
			result = result.format({t_article_indef = GrammarManager.get_indirect_article(entity_name), t_article_def = GrammarManager.get_direct_article(entity_name), t_entity = target_name, t_pronoun1 = GrammarManager.get_pronoun(target.gender, 1), t_pronoun2 = GrammarManager.get_pronoun(target.gender, 2), t_pronoun3 = GrammarManager.get_pronoun(target.gender, 3), t_pronoun4 = GrammarManager.get_pronoun(target.gender, 4)});
		else:
			result = result.format({t_article_indef = "", t_article_def = "", t_entity = target_name, t_pronoun1 = GrammarManager.get_pronoun(target.gender, 1), t_pronoun2 = GrammarManager.get_pronoun(target.gender, 2), t_pronoun3 = GrammarManager.get_pronoun(target.gender, 3), t_pronoun4 = GrammarManager.get_pronoun(target.gender, 4)});
	
	return result;


# Helper functions for intro dialogue
func _get_intro_dialogue(dialogue_entities : Array[EntityController]) -> String:
	if dialogue_entities.size() == 0 :
		return "";
	
	var entity = dialogue_entities[0].current_entity;
	var name = dialogue_entities[0].param.entity_name;
	var key = entity.battle_intro_key;
	
	if dialogue_entities.size() > 1:
		if _all_enemies_same():
			key += "_PLURAL";
			name = dialogue_entities[0].param.entity_name_plural;
		else:
			key += "_GROUP";
	else:
		key += "_SINGLE";
	
	return format_dialogue(tr(key), name, entity);


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


static func _compare_speed(a : EntityController, b : EntityController):
	return EntityController.compare_speed(a, b);


func _is_lowest_valid_player() -> bool:
	if current_player_index == 0 : return true;
	
	for i in range(current_player_index, 0, -1):
		if !players[i - 1].is_defeated && !players[i - 1].skip_decision: return false;
	
	return true;


func _get_next_valid_player_index(val : int) -> int:
	for i in range(val, players.size()):
		if !players[i].is_defeated && (!players[i].is_ready && !players[i].skip_decision): return i;
	
	return players.size();


func _get_prev_valid_player_index(val : int) -> int:
	for i in range(val, 0, -1):
		if !players[i - 1].is_defeated && !players[i - 1].skip_decision : return i - 1;
	
	return -1;


func _get_lowest_valid_player_index() -> int:
	for i in players.size():
		if !players[i].is_defeated : return i;
	
	return -1;


func _on_player_item_consumed(item : Item):
	var id = DataManager.item_database.get_id(item);
	if !player_item_delta.has(id):
		player_item_delta[id] = 0;
	
	player_item_delta[id] -= 1;


func _add_entity_to_battle(entity : Entity):
	if entity != null :
		if _reserve_controllers.size() > 0:
			_spawning = true;
			_current_num_entities = get_num_active_enemies() + 1;
			
			var enemy_controller = _reserve_controllers[0];
			_reserve_controllers.remove_at(0);
			
			while enemy_controller.is_defeat_anim_playing():
				await get_tree().process_frame;
			
			# Reset the entity
			enemy_controller.prev_action = null;
			enemy_controller.current_action = null;
			enemy_controller.current_target.clear();
			enemy_controller.current_entity = entity;
			enemy_controller.visible = true;
			
			# If this has not been registered, register it
			enemy_controller.entity_init(null);
			
			if enemies.has(enemy_controller) :
				_adjust_enemy_name(enemy_controller);
			else:
				_on_enemy_register(enemy_controller);
			
			# Reposition enemies
			var amt = get_num_active_enemies();
			var index = 0;
			var pos_root = enemy_positions.get_child(amt - 1);
			var used : Array[int] = [];
			
			for i in range(enemies.size() - 1, -1, -1):
				var enemy = enemies[i];
				if !enemy.is_defeated:
					index = _get_closest_unused_root_to_entity(enemy, pos_root, used);
					
					if index != -1 :
						var time = BattleManager.ENEMY_REPOSITION_TIME;
						if enemy == enemy_controller : time = 0.0;
						enemy.set_enemy_position((pos_root.get_child(index) as Node2D).position, time);
						used.append(index);
			
			enemy_controller.play_appear_animation();
			
			while is_any_entity_appearing([enemy_controller]) :
				await get_tree().process_frame;
			
			var enemy_spawn_msg = _get_intro_dialogue([enemy_controller]);
			EventManager.on_dialogue_queue.emit(enemy_spawn_msg);
			await EventManager.on_sequence_queue_empty;
			
			_spawning = false;
		else : 
			_reserve_enemies.append(entity);


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
		EventManager.on_player_defeated.disconnect(_on_player_defeated);
		EventManager.on_enemy_defeated.disconnect(_on_enemy_defeated);
		EventManager.on_player_item_consumed.disconnect(_on_player_item_consumed);
		EventManager.add_entity_to_battle.disconnect(_add_entity_to_battle);
		EventManager.learn_move_from_seal.disconnect(_learn_move_from_seal);
	
	if Instance == self:
		Instance = null;
