extends EntitySprite
class_name EntityController

@export var current_entity : Entity;
var move_list : Array[Spell];
var param : EntityParams;
var current_action : Spell;
var current_target : Array[EntityController];
var current_behavior : EntityBehaviorObject;

# constants
const SHAKE_DURATION : float =  0.26;

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


# Initialization
func _ready():
	super._ready();
	
	level = 50; # TEMP CODE: Used to force legitimate calculations for stats
	EventManager.on_turn_begin.connect(_on_turn_begin);
	entity_init();


func entity_init():
	if current_entity != null:
		param = EntityParams.new();
		
		# Fetch text data from localization
		param.entity_name = tr(current_entity.name_key);
		param.entity_name_plural = tr(current_entity.name_key + "_PLURAL");
		param.entity_description = tr(current_entity.description_key);
		
		# Set gender identification for articles and pronouns
		param.entity_gender = current_entity.gender;
		param.entity_generic = current_entity.generic;
		
		# Initialize stats from base stats
		param.entity_hp = ((current_entity.base_hp * 2 * level) / 100) + level + 10;
		param.entity_mp = ((current_entity.base_mp * 2 * level) / 100) + level + 6;
		param.entity_atk = ((current_entity.base_atk * 2 * level) / 100) + 5;
		param.entity_def = ((current_entity.base_def * 2 * level) / 100) + 5;
		param.entity_sp_atk = ((current_entity.base_sp_atk * 2 * level) / 100) + 5;
		param.entity_sp_def = ((current_entity.base_sp_def * 2 * level) / 100) + 5;
		param.entity_spd = ((current_entity.base_spd * 2 * level) / 100) + 5;
		param.entity_crit_modifier = current_entity.base_crit_modifier;
		param.entity_dodge_modifier = current_entity.base_dodge_modifier;
		
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
		
		# NOTE: Players will have the ability to overwrite this
		current_hp = max_hp;
		current_mp = max_mp;
		
		create_move_list();
		
		# TODO: Save data for enemy types.
		# This is variable is largely vestigal from older iterations and may be scrapped.
		is_identified = false;
		
		# TODO: Implement support for effects and modifier arrays
		current_behavior = current_entity.behavior;
		
		# TODO: Reset entity UI



func _on_turn_begin():
	is_ready = false;


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
func apply_damage(val : int, crit : bool, vibrate : bool, hit : bool = true):
	if is_defeated : return;
	
	#print("Damaging for " + str(val));
	
	if val == 0 : 
		if vibrate : 
			if hit : 
				TweenExtensions.shake_position_2d(self, SHAKE_DURATION * 0.7, 22.5, Vector2(7.5, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.35);
			else :
				print("TODO: Dodge");
	else :
		last_hit = val;
		current_hp = clamp(current_hp - val, 0, max_hp);
		
		if current_hp <= 0 :
			on_defeat();
			is_defeated = true;
		
		if vibrate : 
			if crit || is_defeated : 
				TweenExtensions.shake_position_2d(self, SHAKE_DURATION, 45, Vector2(50, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.35);
			else :
				TweenExtensions.shake_position_2d(self, SHAKE_DURATION, 35, Vector2(40, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.35);


func on_defeat():
	print("TODO: Die");


# Setter functions intended to be used to ensure gammeplay callbacks execute
func modify_mp(amt : int):
	current_mp += amt;


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


func get_possible_targets() -> Array[EntityController]:
	var result : Array[EntityController];
	
	match current_action.spell_target:
		Spell.SpellTarget.All:
			for enemy in enemies:
				result.append(enemy);
			for ally in allies:
				result.append(ally);
		Spell.SpellTarget.SingleEnemy:
			for enemy in enemies:
				result.append(enemy);
		Spell.SpellTarget.RandomEnemy:
			for enemy in enemies:
				result.append(enemy);
		Spell.SpellTarget.RandomEnemyPerHit:
			for enemy in enemies:
				result.append(enemy);
		Spell.SpellTarget.AllEnemy:
			for enemy in enemies:
				result.append(enemy);
		Spell.SpellTarget.SingleParty:
			for ally in allies:
				result.append(ally);
		Spell.SpellTarget.AllParty:
			for ally in allies:
				result.append(ally);
		Spell.SpellTarget.Self:
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


# Misc functions
static func compare_speed (a : EntityController, b : EntityController) -> int:
	var priority_a = -10;
	var priority_b = -10;
	
	if a.current_action != null:
		priority_a = a.current_action.spell_priority;
	
	if b.current_action != null:
		priority_b = b.current_action.spell_priority;
	
	if priority_a > priority_b:
		return -1;
	elif priority_b > priority_a:
		return 1;
	
	var a_speed = round(a.param.entity_spd * a.get_speed_modifier());
	var b_speed = round(b.param.entity_spd * b.get_speed_modifier());
	
	# TODO: Speed effect modifiers
	
	if a_speed > b_speed:
		return -1;
	elif b_speed > a_speed:
		return 1;
	
	return 0;

static func compare_speed_tie(a : EntityController, b : EntityController) -> int:
	var result = compare_speed(a, b);
	
	if result == 0:
		if randf() > 0.5:
			return 1;
		else:
			return -1;
	
	return result;


# UI helper/polish functions
func _on_sprite_clicked():
	EventManager.click_target.emit(self);


func _on_destroy():
	if EventManager != null:
		EventManager.on_turn_begin.disconnect(_on_turn_begin);
