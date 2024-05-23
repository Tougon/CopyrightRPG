@tool
extends Resource

class_name Entity

enum Gender { NEUTRAL, MALE, FEMALE, NONBINARY, PLURAL }
enum Type { GENERIC, PLAYER, BOSS }

@export_group("Identification")
@export var name_key : String;
@export var description_key : String;
@export var gender : Gender;
@export var type : Type;
@export var generic : bool = true;

@export_group("Stats")
@export var base_hp : int : 
	set(new_hp):
		if new_hp < 0:
			base_hp = 0;
		else:
			base_hp = new_hp;

@export var base_mp : int : 
	set(new_mp):
		if new_mp < 0:
			base_mp = 0;
		else:
			base_mp = new_mp;

@export var base_atk : int : 
	set(new_atk):
		if new_atk < 0:
			base_atk = 0;
		else:
			base_atk = new_atk;

@export var base_def : int : 
	set(new_def):
		if new_def < 0:
			base_def = 0;
		else:
			base_def = new_def;

@export var base_sp_atk : int : 
	set(new_sp_atk):
		if new_sp_atk < 0:
			base_sp_atk = 0;
		else:
			base_sp_atk = new_sp_atk;

@export var base_sp_def : int : 
	set(new_sp_def):
		if new_sp_def < 0:
			base_sp_def = 0;
		else:
			base_sp_def = new_sp_def;

@export var base_spd : int : 
	set(new_spd):
		if new_spd < 0:
			base_spd = 0;
		else:
			base_spd = new_spd;

@export var base_crit_chance_modifier : float = 1 : 
	set(new_crit_modifier):
		if new_crit_modifier < 0:
			base_crit_chance_modifier = 0;
		else:
			base_crit_chance_modifier = new_crit_modifier;

@export var base_crit_resist_modifier : float = 1 : 
	set(new_crit_modifier):
		if new_crit_modifier < 0:
			base_crit_resist_modifier = 0;
		else:
			base_crit_resist_modifier = new_crit_modifier;

@export var base_dodge_modifier : float = 1 : 
	set(new_dodge_modifier):
		if new_dodge_modifier < 0:
			base_dodge_modifier = 0;
		else:
			base_dodge_modifier = new_dodge_modifier;

@export var luck_curve : Curve;

# TODOGAME: Weakness was unimplemented in the old version.
#@export_group("MODIFIERS")

@export_group("Visuals")
@export var entity_sprites: Array[Texture2D];
@export var battle_intro_key: String;
@export var battle_defeat_key: String;
@export var defeat_anim : AnimationSequenceObject;
@export var head_offset : Vector2;

# TODO: More real tools
@export_group("Moveset and Behavior")
@export var move_list : MoveList;
@export var behavior : EntityBehaviorObject;
