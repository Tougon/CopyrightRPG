extends Resource

class_name Effect

enum EffectType { Volitile, NonVolitile }
enum EffectTarget { User, Target }

@export_group("Universal Effect Parameters")
## Indicates if this event can stack
@export var stackable : bool = false;
## Indicates if the current event should check if the cast was successful or not
@export var cast_success : bool = false;
## Used to identify instances of the effect internally
@export var effect_name : String = "";
## Used to allow for certain effects to be applied independently while using the same name (i.e. stat buffs)
@export var generic : bool = false;
# Order effects should execute at the end of a turn. Higher priorities execute sooner.
@export_range(0, 9) var priority : int = 3;
# Turn limit applied to instances of this effect. Generally only used for displays.
@export_range(0, 20) var turn_limit : int = 3;
@export var effect_type : EffectType = EffectType.Volitile;

# Replacements for BetterEvents
@export var check_success : Array[EffectFunction]
@export var check_remain_active : Array[EffectFunction]
@export var on_activate : Array[EffectFunction]
@export var on_failed_to_activate : Array[EffectFunction]
@export var on_apply : Array[EffectFunction]
@export var on_move_selected : Array[EffectFunction]
@export var on_deactivate : Array[EffectFunction]
@export var on_turn_start : Array[EffectFunction]
@export var on_turn_end : Array[EffectFunction]
@export var on_stack : Array[EffectFunction]


func create_effect_instance(user : EntityController, target : EntityController, cast : SpellCast) -> EffectInstance:
	var instance = EffectInstance.new();
	instance.user = user;
	instance.target = target;
	instance.spell = cast;
	instance.effect = self;
	instance.turn_limit = turn_limit;
	
	return instance;


func get_effect_name(instance : EffectInstance) -> String:
	if generic && instance != null && instance.spell != null && instance.spell.spell != null:
		return instance.spell.spell.spell_name_key + " "  + effect_name;
	return effect_name;


func check_for_cast_success(instance : EffectInstance):
	instance.cast_success = true;


func on_activate_instance(instance : EffectInstance):
	for function in on_activate:
		function.execute(instance);


func on_failed_to_activate_instance(instance : EffectInstance):
	for function in on_failed_to_activate:
		function.execute(instance);
