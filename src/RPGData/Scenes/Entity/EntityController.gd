extends EntitySprite
class_name EntityController

@export var current_entity : Entity;
## Tricks the animation sequence into thinking the entity is scaled differently
@export var use_override_direction : bool = false;
@export var override_direction : Vector2 = Vector2(1, 1);
@export var default_appear_anim : AnimationSequenceObject;
@export var default_dodge_anim : AnimationSequenceObject;
@export var default_defeat_anim : AnimationSequenceObject;

@onready var entity_ui : EntityControllerUI = $"Entity Info Battle";

var move_list : Array[Spell];
# Dictionary of Item, int that determines quantity of items
var item_list : Dictionary;
var param : EntityParams;
var current_action : Spell;
var prev_action : Spell;
var prev_target : Array[EntityController];
var intended_action : Spell;
var intended_target : Array[EntityController];
var action_replaced : bool = false;
var current_item : Item;
var sealing : bool;
var seals_active : bool = true;
var current_target : Array[EntityController];
var current_behavior : EntityBehaviorObject;

# constants
const SHAKE_DURATION : float =  0.26;
const STAT_STAGE_LIMIT : int = 6;

# Runtime values
var level : int;
var max_hp : int;
var max_mp : int;
var atk_stage : int;
var def_stage : int;
var sp_atk_stage : int;
var sp_def_stage : int;
var spd_stage : int;
var evasion_stage : int;
var accuracy_stage : int;

var atk_mods : Dictionary;
var def_mods : Dictionary;
var sp_atk_mods : Dictionary;
var sp_def_mods : Dictionary;
var spd_mods : Dictionary;
var evasion_mods : Dictionary;
var accuracy_mods : Dictionary;

var offense_modifiers : Dictionary;
var defense_modifiers : Dictionary;

var is_defeated : bool = false;
var is_identified : bool = false;
var can_heal : bool = true;
var can_cast : bool = true;

var turn_number : int;

var current_hp : int;
var current_mp : int;
var last_hit : int;

var is_ready : bool = false;
var skip_decision : bool = false;

var allies : Array[EntityController];
var enemies : Array[EntityController];

var action_result : Array[SpellCast];

var effects : Array[EffectInstance];
var properties : Array[EffectInstance];

var sprite_group : int;
var dodge_anim_sequence : AnimationSequence;

var _appear_anim_playing : bool = false;
var _defeat_anim_playing : bool = false;

var turn_seed : float = 0.0;


# Initialization
func _ready():
	super._ready();
	
	if !visible:
		return;
	
	# Used to force legitimate calculations for stats.
	# Will never be used in the final game.
	if level == 0 : 
		level = 50;
	
	EventManager.on_battle_begin.connect(_on_battle_begin);
	EventManager.on_turn_begin.connect(_on_turn_begin);
	EventManager.on_battle_end.connect(_on_battle_end);


func entity_init(params : BattleParams):
	turn_number = 0;
	can_heal = true;
	can_cast = true;
	seals_active = true;
	sealing = false;
	
	prev_target.clear();
	
	if current_entity != null:
		if param != null : 
			param.destroy();
			param.free();
		
		param = current_entity.create_entity_params(level);
		
		print(param.entity_name + ", Lvl " + str(level) + ", HP: " + str(param.entity_hp) + ", MP: " + str(param.entity_mp) + ", Atk: " + str(param.entity_atk) + ", Def: " + str(param.entity_def) + ", SpAtk: " + str(param.entity_sp_atk) + ", SpDef: " + str(param.entity_sp_def) + ", Spd: " + str(param.entity_spd) + ", Lck: " + str(param.entity_luck));
		
		# Reset stats
		max_hp = param.entity_hp;
		max_mp = param.entity_mp;
		atk_stage = 0;
		def_stage = 0;
		sp_atk_stage = 0;
		sp_def_stage = 0;
		spd_stage = 0;
		evasion_stage = 0;
		accuracy_stage = 0;
		
		atk_mods = {};
		def_mods = {};
		sp_atk_mods = {};
		sp_def_mods = {};
		spd_mods = {};
		evasion_mods = {};
		accuracy_mods = {};
		
		offense_modifiers = {};
		defense_modifiers = {};
		
		for mod in current_entity.defense_modifiers:
			if !defense_modifiers.has(mod.flag.flag_name_key):
				defense_modifiers[mod.flag.flag_name_key] = mod.modifier;
		
		# NOTE: Players will have the ability to overwrite this
		current_hp = max_hp;
		current_mp = max_mp;
		
		create_move_list();
		create_item_list();
		
		# Load sprites
		param.entity_sprites = [];
		
		sprite_group = 0;
		
		for i in current_entity.entity_sprites.size():
			param.entity_sprites.append([]);
			
			for path in current_entity.entity_sprites[i].sprites :
				if path != null : load_sprite(path, i);
		
		# TODO: Save data for enemy types.
		# This variable is largely vestigal from older iterations and may be scrapped.
		is_identified = false;
		
		current_behavior = current_entity.behavior;
		
		if param.entity_sprites.size() > 0 :
			if param.entity_sprites[sprite_group].size() > 0:
				sprite.texture = param.entity_sprites[sprite_group][0];
		else : sprite.texture = null;
		_reset_shader_parameters();
		
		sprite.visible = true;
		sprite.position = Vector2.ZERO;
		
		entity_ui.set_specific_entity_info(self);
		
		is_ready = false;
		is_defeated = false;
		
		# Remove any possible extant effects
		effects.clear();


func load_sprite(path : String, group : int):
	if ResourceLoader.exists(path, "Texture2D"):
		var sprite = ResourceLoader.load(path, "Texture2D") as Texture2D;
		param.entity_sprites[group].append(sprite);


func _on_battle_begin(params : BattleParams):
	current_entity = null;
	prev_action = null;
	current_target.clear();
	entity_init(params);


func _on_turn_begin():
	is_ready = false;


func _on_battle_end(result : BattleResult):
	sprite.texture = null;
	if param != null : 
		param.destroy();
		param.free();


func create_move_list():
	move_list.clear();
	
	if current_entity != null:
		if current_entity.move_list != null:
			for move in current_entity.move_list.list:
				if move != null && move.level <= level:
					move_list.append(move.spell);
		else :
			print(current_entity.name_key + " has no move list!")


func create_item_list():
	item_list.clear();
	# IMPORTANT
	# Very Much Temp Code, please remove when items are fully supported
	item_list[DataManager.item_database.get_item(0)] = 2;


# Gameplay Functions
func select_action():
	if current_behavior != null && current_behavior.turn_behavior.size() > 0:
		var behavior : EntityBehavior = null;
		
		if turn_number == 1 && current_behavior.first_turn_behavior != null:
			behavior = current_behavior.first_turn_behavior;
		else:
			var valid_behavior = false;
			while !valid_behavior :
				var turn_index = (turn_number - 1) % current_behavior.turn_behavior.size();
				behavior = current_behavior.turn_behavior[turn_index];
				
				if behavior.is_behavior_active(self, allies, enemies):
					valid_behavior = true;
				else : turn_number += 1;
		
		if behavior != null:
			var result = behavior.get_result(self, allies, enemies);
			
			if result.action_success:
				current_action = move_list[clamp(result.action_id, 0, move_list.size())];
				sealing = result.action_sealing;
				_set_seal_id(result.action_seal_id);
				
				if check_target_match(current_action, result):
					set_target(result.trigger_entity);
				else:
					set_target();
			else:
				select_random_action();
			
			if result != null :
				result.free();
	else:
		select_random_action();


func _set_seal_id(id : int):
	pass;


func check_target_match(spell : Spell, result : BehaviorCheckResult) -> bool:
	match spell.spell_target:
		Spell.SpellTarget.Self:
			return result.check_target == BehaviorCheck.CheckTarget.Self;
		Spell.SpellTarget.SingleEnemy:
			return result.check_target == BehaviorCheck.CheckTarget.Targets;
		Spell.SpellTarget.SingleParty:
			return result.check_target == BehaviorCheck.CheckTarget.Allies;
	
	return false;


func select_random_action():
	current_action = move_list[randi_range(0, move_list.size()-1)];
	set_target();


func set_target(trigger : EntityController = null):
	var available = get_possible_targets(null, true);
	var index = randi_range(0, available.size() - 1);
	
	match current_action.spell_target:
		Spell.SpellTarget.SingleEnemy:
			if trigger != null :
				current_target = [trigger];
			else:
				current_target = [available[index]];
		Spell.SpellTarget.SingleParty:
			if trigger != null :
				current_target = [trigger];
			else:
				current_target = [available[index]];
		Spell.SpellTarget.RandomEnemy:
			current_target = [available[index]];
		Spell.SpellTarget.Self:
			current_target = [self];
		_:
			current_target = available;


# Item Functions
func can_use_item(item : Item = null) -> bool:
	if item == null : item = current_item;
	if item == null : return false;
	
	if item is ConsumableItem :
		# If the item would affect any target, it can be used.
		for target in current_target:
			if (item as ConsumableItem).check_can_use_item_battle(self, target):
				return true;
		
		return false;
	
	return true;


func consume_item(item : Item = null):
	if item == null : item = current_item;
	if item == null : return;
	
	subtract_item(item)
	if item_list.has(item) && item_list[item] <= 0 : item_list.erase(item);


func add_item(item : Item):
	if item == null : return;
	
	if item_list.has(item) : item_list[item] += 1;
	else : item_list[item] = 1;
	#print(item_list[item])


func subtract_item(item : Item):
	if item == null || !item_list.has(item) : return;
	
	item_list[current_item] -= 1;
	#print(item_list[item])


func has_any_items() -> bool:
	for key in item_list.keys():
		if item_list[key] > 0:
			return true;
	
	return false;


# HP and MP modification
func apply_damage(val : int, crit : bool, vibrate : bool, hit : bool = true, damage_time : float = 0.35, damage_delay : float = 0.0, shake_duration : float = 0.0, shake_decay : float = 0.35, dodge_anyway : bool = true):
	if is_defeated : return;
	
	if damage_delay > 0:
		await get_tree().create_timer(damage_delay).timeout;
	
	if dodge_anim_sequence != null :
		dodge_anim_sequence.kill();
	
	var shake = SHAKE_DURATION;
	if shake_duration > 0:
		shake = shake_duration
	if damage_time < shake:
		shake = damage_time;
	
	if val == 0 : 
		if vibrate : 
			if hit : 
				TweenExtensions.shake_position_2d(sprite, shake * 0.7, 22.5, Vector2(7.5, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.35);
			else :
				var dodge_anim = default_dodge_anim;
				if current_entity.dodge_anim != null : dodge_anim = current_entity.dodge_anim;
				
				dodge_anim_sequence = AnimationSequence.new(get_tree(), dodge_anim, self, [self], [null]);
				dodge_anim_sequence.sequence_ended.connect(_free_dodge_sequence);
				dodge_anim_sequence.sequence_start();
		else :
			if dodge_anyway && !hit:
				var dodge_anim = default_dodge_anim;
				if current_entity.dodge_anim != null : dodge_anim = current_entity.dodge_anim;
				
				dodge_anim_sequence = AnimationSequence.new(get_tree(), dodge_anim, self, [self], [null]);
				dodge_anim_sequence.sequence_ended.connect(_free_dodge_sequence);
				dodge_anim_sequence.sequence_start();
	else :
		last_hit = val;
		current_hp = clamp(current_hp - val, 0, max_hp);
		
		if current_hp <= 0 :
			on_defeat();
			is_defeated = true;
			on_damage(crit);
		elif val > 0 : 
			on_damage(crit);
			set_damage_sprite(damage_time);
		else :
			on_heal();
		
		if is_defeated :
			if param.entity_sprites[sprite_group].size() > 1:
				sprite.texture = param.entity_sprites[sprite_group][1];
			
			TweenExtensions.shake_position_2d(sprite, shake, 47.5, Vector2(50, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, shake_decay);
			await get_tree().create_timer(shake).timeout;
			_play_defeat_animation();
		
		elif vibrate : 
			if crit : 
				TweenExtensions.shake_position_2d(sprite, shake, 47.5, Vector2(50, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, shake_decay);
			else :
				TweenExtensions.shake_position_2d(sprite, shake, 35, Vector2(40, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, shake_decay);
		
		if crit && BattleManager.async_crit_text: 
			var msg = tr("T_BATTLE_ACTION_CRITICAL_GENERIC").format({entity = param.entity_name});
			EventManager.on_message_queue.emit(msg);


func _free_dodge_sequence():
	if dodge_anim_sequence != null :
		dodge_anim_sequence.sequence_ended.disconnect(_free_dodge_sequence);
		await get_tree().process_frame;
		dodge_anim_sequence.free();
		dodge_anim_sequence = null;


func set_damage_sprite(damage_time : float):
	if param.entity_sprites[sprite_group].size() > 1:
		var previous = sprite.texture;
		sprite.texture = param.entity_sprites[sprite_group][1];
		await get_tree().create_timer(damage_time).timeout
		sprite.texture = previous;


func update_hp_ui():
	if entity_ui : 
		entity_ui.change_hp(current_hp);


func update_mp_ui():
	if entity_ui : 
		entity_ui.change_mp(current_mp);


func on_heal():
	pass;


func on_damage(crit : bool):
	pass;


func on_defeat():
	atk_stage = 0;
	def_stage = 0;
	sp_atk_stage = 0;
	sp_def_stage = 0;
	spd_stage = 0;
	accuracy_stage = 0;
	evasion_stage = 0;
	
	# TODO: If entity is the final entity alive on either side, do not display text
	
	for property in properties:
		remove_effect(property, false);
	
	for effect in effects:
		if effect.effect.effect_type == Effect.EffectType.Volitile:
			remove_effect(effect, false);
	
	atk_mods.clear();
	def_mods.clear();
	sp_atk_mods.clear();
	sp_def_mods.clear();
	spd_mods.clear();
	accuracy_mods.clear();
	evasion_mods.clear();
	
	sealing = false;
	EventManager.on_entity_defeated.emit(self);
	
	current_item = null;


func revive(hp : int):
	print("Reviving:")
	is_defeated = false;
	current_hp = hp;
	last_hit = -hp;
	current_action == null;


func play_appear_animation():
	sprite.visible = false;
	
	var appear_anim = default_appear_anim;
	if current_entity.appear_anim != null : appear_anim = current_entity.appear_anim;
	
	_appear_anim_playing = true;
	
	var animation_seq = AnimationSequence.new(get_tree(), appear_anim, self, [self], [null]);
	animation_seq.sequence_ended.connect(_on_appear_anim_complete);
	animation_seq.sequence_start();


func _on_appear_anim_complete():
	_appear_anim_playing = false;

func is_appear_anim_playing() -> bool:
	return _appear_anim_playing;


func _play_defeat_animation():
	var defeat_anim = default_defeat_anim;
	if current_entity.defeat_anim != null : defeat_anim = current_entity.defeat_anim;
	
	_defeat_anim_playing = true;
	
	var animation_seq = AnimationSequence.new(get_tree(), defeat_anim, self, [self], [null]);
	
	if current_entity.type == Entity.Type.GENERIC:
		_on_defeat_complete();
		animation_seq.sequence_ended.connect(_on_defeat_anim_complete);
		animation_seq.sequence_start();
	else:
		animation_seq.sequence_ended.connect(_on_defeat_complete);
		animation_seq.sequence_ended.connect(_on_defeat_anim_complete);
		EventManager.on_sequence_queue.emit(animation_seq);


func _on_defeat_complete():
	pass;


func _on_defeat_anim_complete():
	_defeat_anim_playing = false;


func is_defeat_anim_playing() -> bool:
	return _defeat_anim_playing;


# Setter functions intended to be used to ensure gammeplay callbacks execute
func modify_mp(amt : int):
	current_mp = clamp(current_mp + amt, 0, max_mp);
	update_mp_ui();


# Getter functions for UI and other areas
func get_hp_percent() -> float:
	return float(current_hp) / float(max_hp);


func get_mp_percent() -> float:
	return float(current_mp) / float(max_mp);


func _get_stat_modifier(stage : int) -> float:
	return max(2.0, 2.0 + stage) / max(2.0, 2.0 - stage);


func get_attack_modifier() -> float:
	return _get_stat_modifier(atk_stage);


func get_defense_modifier() -> float:
	return _get_stat_modifier(def_stage);


func get_sp_attack_modifier() -> float:
	return _get_stat_modifier(sp_atk_stage);


func get_sp_defense_modifier() -> float:
	return _get_stat_modifier(sp_def_stage);


func get_speed_modifier() -> float:
	return _get_stat_modifier(spd_stage);


func get_accuracy() -> float:
	return param.entity_accuracy_modifier;


func get_evasion() -> float:
	return param.entity_dodge_modifier;


func get_possible_targets(spell : Spell = null, add_defeated : bool = false) -> Array[EntityController]:
	var result : Array[EntityController];
	
	var action_to_check = current_action;
	
	if spell != null : action_to_check = spell;
	
	match action_to_check.spell_target:
		Spell.SpellTarget.All:
			for enemy in enemies:
				if !enemy.is_defeated || add_defeated:
					result.append(enemy);
			for ally in allies:
				if !ally.is_defeated || add_defeated:
					result.append(ally);
		Spell.SpellTarget.SingleEnemy:
			for enemy in enemies:
				if !enemy.is_defeated || add_defeated:
					result.append(enemy);
		Spell.SpellTarget.RandomEnemy:
			for enemy in enemies:
				if !enemy.is_defeated || add_defeated:
					result.append(enemy);
		Spell.SpellTarget.RandomEnemyPerHit:
			for enemy in enemies:
				if !enemy.is_defeated || add_defeated:
					result.append(enemy);
		Spell.SpellTarget.AllEnemy:
			for enemy in enemies:
				if !enemy.is_defeated || add_defeated:
					result.append(enemy);
		Spell.SpellTarget.AllEnemyExcept:
			for enemy in enemies:
				if !enemy.is_defeated || add_defeated:
					result.append(enemy);
		Spell.SpellTarget.AllExceptSelf:
			for enemy in enemies:
				if !enemy.is_defeated || add_defeated:
					result.append(enemy);
			for ally in allies:
				if (!ally.is_defeated || add_defeated) && ally != self:
					result.append(ally);
		Spell.SpellTarget.SingleParty:
			for ally in allies:
				if (!ally.is_defeated || add_defeated) && (!action_to_check.ignore_self || (action_to_check.ignore_self && ally != self)):
					result.append(ally);
		Spell.SpellTarget.AllParty:
			for ally in allies:
				if (!ally.is_defeated || add_defeated) && (!action_to_check.ignore_self || (action_to_check.ignore_self && ally != self)):
					result.append(ally);
		Spell.SpellTarget.Self:
			if !is_defeated || add_defeated:
				result.append(self);
	
	return result;


# Stat Modifier Getters
func get_attack_modifiers():
	return atk_mods.values();


func get_defense_modifiers():
	return def_mods.values();


func get_sp_attack_modifiers():
	return sp_atk_mods.values();


func get_sp_defense_modifiers():
	return sp_def_mods.values();


func get_speed_modifiers():
	return spd_mods.values();


func get_evasion_modifiers():
	return evasion_mods.values();


func get_accuracy_modifiers():
	return accuracy_mods.values();


# Effect functions
# NOTE: It is unclear to me how GDScript/Python handle removing items in a loop.
# UPDATE: Not well! I've reworked the loops so that no effects have their function skipped.
func execute_turn_start_effects():
	var index = 0;
	
	while index < effects.size():
		var effect = effects[index]
		effect.on_turn_start();
		
		if effects.has(effect):
			index += 1;


func execute_remain_active_check():
	var index = 0;
	
	while index < effects.size():
		var effect = effects[index]
		effect.check_remain_active();
		
		if effects.has(effect):
			index += 1;


func execute_move_selected_effects():
	var index = 0;
	
	while index < effects.size():
		var effect = effects[index]
		effect.on_move_selected();
		
		if effects.has(effect):
			index += 1;


func execute_move_completed_effects():
	var index = 0;
	
	while index < effects.size():
		var effect = effects[index]
		effect.on_move_completed();
		
		if effects.has(effect):
			index += 1;


func execute_turn_end_effects():
	var index = 0;
	
	while index < effects.size():
		var effect = effects[index]
		effect.on_turn_end();
		
		if effects.has(effect):
			index += 1;


func apply_effect(instance : EffectInstance):
	if is_defeated : return;
	
	if instance.effect.repeatable:
		effects.append(instance);
		instance.on_apply();
	
	elif instance.effect.stackable:
		var existing_instance = _find_effect_by_name(instance.get_effect_name());
		
		if existing_instance != null :
			existing_instance.on_stack();
		else :
			effects.append(instance);
			instance.on_apply();
	
	elif !_find_effect_by_name(instance.get_effect_name()) :
		effects.append(instance);
		instance.on_apply();
	
	# Sort effects by priority
	effects.sort_custom(compare_effect_priority);


func remove_effect_from_resource(effect : Effect, deactivate : bool = true):
	var inst = _find_effect_by_name(effect.effect_name);
	if inst != null :
		remove_effect(inst, deactivate);

func remove_effect(instance : EffectInstance, deactivate : bool = true):
	if effects.has(instance) :
		if deactivate : instance.on_deactivate();
		effects.erase(instance);
		await get_tree().process_frame;
		instance.free();


func _find_effect_by_name(name : String) -> EffectInstance:
	for effect in effects:
		if effect.get_effect_name() == name:
			return effect;
	return null;


func has_effect(name : String) -> bool:
	for effect in effects:
		if effect.get_effect_name() == name:
			return true;
	return false;


# Effect functions
func apply_property(instance : EffectInstance):
	properties.append(instance);


func clear_properties():
	for p in properties:
		if p == null : continue;
		p.on_deactivate();
		p.free();
	properties.clear();


# Misc functions
func reset_action():
	if !skip_decision :
		current_action = null;
		action_result = [null];


static func compare_speed (a : EntityController, b : EntityController) -> bool:
	var priority_a = -10;
	var priority_b = -10;
	
	if a.current_action != null:
		priority_a = a.current_action.spell_priority;
	
	if b.current_action != null:
		priority_b = b.current_action.spell_priority;
	
	if priority_a > priority_b:
		return true;
	elif priority_b > priority_a:
		return false;
	
	var a_speed = round(a.param.entity_spd * a.get_speed_modifier());
	var b_speed = round(b.param.entity_spd * b.get_speed_modifier());
	
	for mod in a.get_speed_modifiers(): a_speed *= mod;
	for mod in b.get_speed_modifiers(): b_speed *= mod;
	
	if a_speed > b_speed:
		return true;
	elif b_speed > a_speed:
		return false;
	
	# Randomize if speed is tied
	return a.turn_seed > b.turn_seed;


# What the hell is this?
# Seems redundant given that compare_speed already handles ties.
static func compare_speed_tie(a : EntityController, b : EntityController) -> bool:
	var result = compare_speed(a, b);
	
	if result == 0:
		if randf() > 0.5:
			return true;
		else:
			return false;
	
	return result;


static func compare_effect_priority (a : EffectInstance, b : EffectInstance) -> bool:
	var priority_a = -10;
	var priority_b = -10;
	
	if a.effect != null:
		priority_a = a.effect.priority;
	
	if b.effect != null:
		priority_b = b.effect.priority;
	
	if priority_a > priority_b:
		return true;
	elif priority_b > priority_a:
		return false;
	
	return false;


# UI helper/polish functions
func get_sprite_top_offset() -> Vector2:
	if current_entity != null :
		return current_entity.head_offset;
	
	return Vector2.ZERO;


func get_sprite_bottom_offset() -> Vector2:
	if current_entity != null :
		return current_entity.foot_offset;
	
	return Vector2.ZERO;


func _on_sprite_clicked():
	EventManager.click_target.emit(self);


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_begin.disconnect(_on_battle_begin);
		EventManager.on_turn_begin.disconnect(_on_turn_begin);
		EventManager.on_battle_end.disconnect(_on_battle_end);
