extends Resource

class_name Effect

enum EffectType { Volitile, NonVolitile }
enum EffectTarget { User, Target }

@export_group("Universal Effect Parameters")
## Indicates if the current event should check if the cast was successful or not
@export var cast_success : bool = false;
@export var effect_name : String = "";
## Used to allow for certain effects to be applied independently while using the same name (i.e. stat buffs)
@export var generic : bool = false;
# Order effects should execute at the end of a turn. Higher priorities execute sooner.
@export_range(0, 9) var priority : int = 3;
# Turn limit applied to instances of this effect. Generally only used for displays.
@export_range(0, 20) var turn_limit : int = 3;
@export var effect_type : EffectType = EffectType.Volitile;


func get_effect_name() -> String:
	# TODO: Extend
	return effect_name;


# This function will be overwritten by the child effects to do the actual checks
func check_for_cast_success(instance : EffectInstance):
	instance.cast_success = true;
