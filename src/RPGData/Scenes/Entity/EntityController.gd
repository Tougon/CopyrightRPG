extends EntitySprite
class_name EntityController

@export var current_entity : Entity;
var move_list : Array[Spell];
var param : EntityParams;

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
var is_identified : bool = false;

var current_hp : int;
var current_mp : int;

var is_ready : bool = false;


# Called when the node enters the scene tree for the first time.
func _ready():
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
		
		# NOTE: Players will have the ability to overwrite this
		current_hp = max_hp;
		current_mp = max_mp;
		
		create_move_list();
		
		# TODO: Save data for enemy types.
		# This is variable is largely vestigal from older iterations and may be scrapped.
		is_identified = false;
		
		# TODO: Implement support for effects and modifier arrays
		
		# TODO: Reset entity UI


func _on_turn_begin():
	is_ready = false;


func create_move_list():
	move_list.clear();
	
	if current_entity:
		for move in current_entity.move_list.list:
			if move != null && move.level <= level:
				move_list.append(move.spell);


# Getter functions for UI and other areas
func get_hp_percent() -> float:
	return float(current_hp) / float(max_hp);


func get_mp_percent() -> float:
	return float(current_mp) / float(max_mp);


func _on_destroy():
	if EventManager != null:
		EventManager.on_turn_begin.disconnect(_on_turn_begin);
