extends EntitySprite
class_name EntityController

@export var current_entity : Entity;
## Tricks the animation sequence into thinking the entity is scaled differently
@export var use_override_direction : bool = false;
@export var override_direction : Vector2 = Vector2(1, 1);
@export var default_dodge_anim : AnimationSequenceObject;
@export var default_defeat_anim : AnimationSequenceObject;

@onready var entity_ui : EntityControllerUI = $"Entity Info Battle";

var move_list : Array[Spell];
var param : EntityParams;
var current_action : Spell;
var prev_action : Spell;
var sealing : bool;
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
var flag_modifiers : Dictionary;

var is_defeated : bool = false;
var is_identified : bool = false;

var turn_number : int;

var current_hp : int;
var current_mp : int;
var last_hit : int;

var is_ready : bool = false;

var allies : Array[EntityController];
var enemies : Array[EntityController];

var action_result : Array[SpellCast];

var effects : Array[EffectInstance];
var properties : Array[EffectInstance];


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
	if current_entity != null:
		
		if param != null : param.free();
		
		param = EntityParams.new();
		
		# Fetch text data from localization
		param.entity_name = tr(current_entity.name_key);
		param.entity_name_plural = tr(current_entity.name_key + "_PLURAL");
		param.entity_description = tr(current_entity.description_key);
		
		# Set gender identification for articles and pronouns
		param.entity_gender = current_entity.gender;
		param.entity_generic = current_entity.generic;
		
		# Initialize stats from base stats
		param.entity_hp = current_entity.get_hp(level);
		param.entity_mp = current_entity.get_mp(level);
		param.entity_atk = current_entity.get_atk(level);
		param.entity_def = current_entity.get_def(level);
		param.entity_sp_atk = current_entity.get_sp_atk(level);
		param.entity_sp_def = current_entity.get_sp_def(level);
		param.entity_spd = current_entity.get_spd(level);
		
		param.entity_crit_chance_modifier = current_entity.base_crit_chance_modifier;
		param.entity_crit_resist_modifier = current_entity.base_crit_resist_modifier;
		param.entity_dodge_modifier = current_entity.base_dodge_modifier;
		param.entity_luck = current_entity.get_lck(level);
		
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
		
		flag_modifiers = {};
		
		for mod in current_entity.weakness:
			if !flag_modifiers.has(mod.flag.flag_name_key):
				flag_modifiers[mod.flag.flag_name_key] = mod.modifier;
		
		for mod in current_entity.resistance:
			if !flag_modifiers.has(mod.flag.flag_name_key):
				flag_modifiers[mod.flag.flag_name_key] = mod.modifier;
		
		# NOTE: Players will have the ability to overwrite this
		current_hp = max_hp;
		current_mp = max_mp;
		
		create_move_list();
		
		# Load sprites
		
		# TODOGAME: Save data for enemy types.
		# This variable is largely vestigal from older iterations and may be scrapped.
		is_identified = false;
		
		current_behavior = current_entity.behavior;
		
		if param.entity_sprites.size() > 0 :
			sprite.texture = param.entity_sprites[0];
		_reset_shader_parameters();
		
		sprite.visible = true;
		
		entity_ui.set_specific_entity_info(self);
		
		is_ready = false;
		is_defeated = false;


func _on_battle_begin(params : BattleParams):
	entity_init(params);


func _on_turn_begin():
	is_ready = false;


func _on_battle_end(result : BattleResult):
	if param != null : param.free();


func create_move_list():
	move_list.clear();
	
	if current_entity != null && current_entity.move_list != null:
		for move in current_entity.move_list.list:
			if move != null && move.level <= level:
				move_list.append(move.spell);


# Gameplay Functions
func select_action():
	if current_behavior != null && current_behavior.turn_behavior.size() > 0:
		var behavior : EntityBehavior = null;
		
		if turn_number == 1 && current_behavior.first_turn_behavior != null:
			behavior = current_behavior.first_turn_behavior;
		else:
			var turn_index = (turn_number - 1) % current_behavior.turn_behavior.size();
			behavior = current_behavior.turn_behavior[turn_index];
		
		if behavior != null:
			var result = behavior.get_result(self, allies, enemies);
			
			if result.action_success:
				current_action = move_list[clamp(result.action_id, 0, move_list.size())];
				sealing = result.action_sealing;
				
				if check_target_match(current_action, result):
					set_target(result.trigger_entity);
				else:
					set_target();
			else:
				select_random_action();
	else:
		select_random_action();


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
	var available = get_possible_targets();
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


# HP and MP modification
func apply_damage(val : int, crit : bool, vibrate : bool, hit : bool = true, damage_time : float = 0.35, damage_delay : float = 0.0, shake_duration : float = 0.0, shake_decay : float = 0.35, dodge_anyway : bool = true):
	if is_defeated : return;
	
	if damage_delay > 0:
		await get_tree().create_timer(damage_delay).timeout;
	
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
				
				var animation_seq = AnimationSequence.new(get_tree(), dodge_anim, self, [self], [null]);
				animation_seq.sequence_start();
		else :
			if dodge_anyway && !hit:
				var dodge_anim = default_dodge_anim;
				if current_entity.dodge_anim != null : dodge_anim = current_entity.dodge_anim;
				
				var animation_seq = AnimationSequence.new(get_tree(), dodge_anim, self, [self], [null]);
				animation_seq.sequence_start();
	else :
		last_hit = val;
		current_hp = clamp(current_hp - val, 0, max_hp);
		
		if current_hp <= 0 :
			on_defeat();
			is_defeated = true;
		else : set_damage_sprite(damage_time);
		
		if is_defeated :
			if param.entity_sprites.size() > 1:
				sprite.texture = param.entity_sprites[1];
			
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


func set_damage_sprite(damage_time : float):
	if param.entity_sprites.size() > 1:
		var previous = sprite.texture;
		sprite.texture = param.entity_sprites[1];
		await get_tree().create_timer(damage_time).timeout
		sprite.texture = previous;


func update_hp_ui():
	if entity_ui : 
		entity_ui.change_hp(current_hp);


func update_mp_ui():
	if entity_ui : 
		entity_ui.change_mp(current_mp);


func on_defeat():
	atk_stage = 0;
	def_stage = 0;
	sp_atk_stage = 0;
	sp_def_stage = 0;
	spd_stage = 0;
	accuracy_stage = 0;
	evasion_stage = 0;
	
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


func _play_defeat_animation():
	var defeat_anim = default_defeat_anim;
	if current_entity.defeat_anim != null : defeat_anim = current_entity.defeat_anim;
	
	var animation_seq = AnimationSequence.new(get_tree(), defeat_anim, self, [self], [null]);
	
	if current_entity.type == Entity.Type.GENERIC:
		_on_defeat_complete();
		animation_seq.sequence_start();
	else:
		animation_seq.sequence_ended.connect(_on_defeat_complete);
		EventManager.on_sequence_queue.emit(animation_seq);


func _on_defeat_complete():
	pass;


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
	return 1;


func get_evasion() -> float:
	return param.entity_dodge_modifier;


func get_possible_targets(spell : Spell = null) -> Array[EntityController]:
	var result : Array[EntityController];
	
	var action_to_check = current_action;
	
	if spell != null : action_to_check = spell;
	
	match action_to_check.spell_target:
		Spell.SpellTarget.All:
			for enemy in enemies:
				if !enemy.is_defeated:
					result.append(enemy);
			for ally in allies:
				if !ally.is_defeated:
					result.append(ally);
		Spell.SpellTarget.SingleEnemy:
			for enemy in enemies:
				if !enemy.is_defeated:
					result.append(enemy);
		Spell.SpellTarget.RandomEnemy:
			for enemy in enemies:
				if !enemy.is_defeated:
					result.append(enemy);
		Spell.SpellTarget.RandomEnemyPerHit:
			for enemy in enemies:
				if !enemy.is_defeated:
					result.append(enemy);
		Spell.SpellTarget.AllEnemy:
			for enemy in enemies:
				if !enemy.is_defeated:
					result.append(enemy);
		Spell.SpellTarget.AllEnemyExcept:
			for enemy in enemies:
				if !enemy.is_defeated:
					result.append(enemy);
		Spell.SpellTarget.AllExceptSelf:
			for enemy in enemies:
				if !enemy.is_defeated:
					result.append(enemy);
			for ally in allies:
				if !ally.is_defeated && !ally == self:
					result.append(ally);
		Spell.SpellTarget.SingleParty:
			for ally in allies:
				if !ally.is_defeated:
					result.append(ally);
		Spell.SpellTarget.AllParty:
			for ally in allies:
				if !ally.is_defeated:
					result.append(ally);
		Spell.SpellTarget.Self:
			if !is_defeated:
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
func execute_turn_start_effects():
	for effect in effects :
		effect.on_turn_start();


func execute_remain_active_check():
	for effect in effects :
		effect.check_remain_active();


func execute_move_selected_effects():
	for effect in effects :
		effect.on_move_selected();


func execute_move_completed_effects():
	for effect in effects :
		effect.on_move_completed();


func execute_turn_end_effects():
	for effect in effects :
		effect.on_turn_end();


func apply_effect(instance : EffectInstance):
	if is_defeated : return;
	
	if instance.effect.stackable:
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


func remove_effect(instance : EffectInstance, deactivate : bool = true):
	if effects.has(instance) :
		if deactivate : instance.on_deactivate();
		effects.erase(instance);


func _find_effect_by_name(name : String) -> EffectInstance:
	for effect in effects:
		if effect.get_effect_name() == name:
			return effect;
	return null;


# Effect functions
func apply_property(instance : EffectInstance):
	properties.append(instance);


func clear_properties():
	for p in properties:
		p.on_deactivate();
	properties.clear();


# Misc functions
func reset_action():
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
	
	return false;


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
func _on_sprite_clicked():
	EventManager.click_target.emit(self);


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_begin.disconnect(_on_battle_begin);
		EventManager.on_turn_begin.disconnect(_on_turn_begin);
		EventManager.on_battle_end.disconnect(_on_battle_end);
