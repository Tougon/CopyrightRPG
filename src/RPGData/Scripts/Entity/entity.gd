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
@export var hp : EntityStat;
func get_hp(level : int) -> int:
	if hp == null : return 50;
	return hp.get_current(level);

@export var mp : EntityStat;
func get_mp(level : int) -> int:
	if mp == null : return 50;
	return mp.get_current(level);

@export var atk : EntityStat;
func get_atk(level : int) -> int:
	if atk == null : return 50;
	return atk.get_current(level);

@export var def : EntityStat;
func get_def(level : int) -> int:
	if def == null : return 50;
	return def.get_current(level);

@export var sp_atk : EntityStat;
func get_sp_atk(level : int) -> int:
	if sp_atk == null : return 50;
	return sp_atk.get_current(level);

@export var sp_def : EntityStat;
func get_sp_def(level : int) -> int:
	if sp_def == null : return 50;
	return sp_def.get_current(level);

@export var spd : EntityStat;
func get_spd(level : int) -> int:
	if spd == null : return 50;
	return spd.get_current(level);

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

@export var luck : EntityStatFloat;
func get_lck(level : int) -> float:
	if luck == null : return 1;
	return luck.get_current(level);

@export var level_exp : EntityStat;
func get_level_exp(level : int) -> int:
	if level_exp == null : return 50;
	return level_exp.get_current(level);

# TODO: Weakness was unimplemented in the old version.
@export_group("Modifiers")
@export var weakness : Array[FlagModifier];
@export var resistance : Array[FlagModifier];
@export var min_level : int = 50;
@export var max_level : int = 50 :
	set(new_max_level):
		if new_max_level < min_level:
			max_level = min_level;
		else:
			max_level = new_max_level;

@export var level_curve : Curve;

@export_group("Rewards")
@export var reward_exp : EntityStat;
func get_reward_exp(level : int) -> int:
	if reward_exp == null : return 50;
	return reward_exp.get_current(level);

@export_group("Visuals")
@export_file("*.png") var entity_sprites: Array[String];
@export var battle_intro_key: String;
@export var battle_defeat_key: String;
@export var dodge_anim : AnimationSequenceObject;
@export var defeat_anim : AnimationSequenceObject;
@export var head_offset : Vector2;
@export_file("*.tres") var entity_video: String;
@export_file("*.tres") var entity_video_material: String;
@export_file("*.tres") var entity_thought_pattern_material: String;

# TODO: More real tools
@export_group("Moveset and Behavior")
@export var move_list : MoveList;
@export var behavior : EntityBehaviorObject;
