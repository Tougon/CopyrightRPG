extends Resource

class_name Effect

enum EffectType { Volitile, NonVolitile }
enum EffectTarget { User, Target }
enum EffectCheckType { AND, OR }

@export_group("Universal Effect Parameters")
## Indicates if this effect can stack
@export var stackable : bool = false;
## Indicates if the current effect should check if the cast was successful or not
## Seems to be vestigal. If we run into problems, restore this.
#@export var cast_success : bool = false;
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
@export_group("Effect Functions")
@export var check_success_type : EffectCheckType;
@export var check_success : Array[EffectFunction]
@export var check_remain_active_type : EffectCheckType;
@export var check_remain_active : Array[EffectFunction]
@export var on_activate : Array[EffectFunction]
@export var on_failed_to_activate : Array[EffectFunction]
@export var on_apply : Array[EffectFunction]
@export var on_move_selected : Array[EffectFunction]
@export var on_move_completed : Array[EffectFunction]
@export var on_deactivate : Array[EffectFunction]
@export var on_turn_start : Array[EffectFunction]
@export var on_turn_end : Array[EffectFunction]
@export var on_stack : Array[EffectFunction]


func create_effect_instance(user : EntityController, target : EntityController, cast : SpellCast) -> EffectInstance:
	var instance = EffectInstance.new();
	instance.user = user;
	instance.target = target;
	instance.spell = cast;
	if cast != null : instance.spell_data = cast.spell;
	instance.effect = self;
	instance.turn_limit = turn_limit;
	
	return instance;


func get_effect_name(instance : EffectInstance) -> String:
	if generic && instance != null && instance.spell_data != null:
		return instance.spell_data.spell_name_key + " "  + effect_name;
	return effect_name;


func check_for_cast_success(instance : EffectInstance):
	instance.cast_success = true;
	for function in check_success:
		if function == null : continue;
		function.execute(instance);
		
		if check_success_type == EffectCheckType.AND && instance.cast_success == false:
			return;
		elif check_success_type == EffectCheckType.OR && instance.cast_success == true:
			return;


func check_for_remain_active(instance : EffectInstance):
	instance.cast_success = true;
	for function in check_remain_active:
		if function == null : continue;
		function.execute(instance);
		
		if check_remain_active_type == EffectCheckType.AND && instance.cast_success == false:
			return;
		elif check_remain_active_type == EffectCheckType.OR && instance.cast_success == true:
			return;


func on_activate_instance(instance : EffectInstance):
	for function in on_activate:
		if function == null : continue;
		function.execute(instance);


func on_failed_to_activate_instance(instance : EffectInstance):
	for function in on_failed_to_activate:
		if function == null : continue;
		function.execute(instance);


func on_apply_instance(instance : EffectInstance):
	for function in on_apply:
		if function == null : continue;
		function.execute(instance);


func on_stack_instance(instance : EffectInstance):
	for function in on_stack:
		if function == null : continue;
		function.execute(instance);


func on_deactivate_instance(instance : EffectInstance):
	for function in on_deactivate:
		if function == null : continue;
		function.execute(instance);


func on_turn_start_instance(instance : EffectInstance):
	for function in on_turn_start:
		if function == null : continue;
		function.execute(instance);


func on_move_selected_instance(instance : EffectInstance):
	for function in on_move_selected:
		if function == null : continue;
		function.execute(instance);


func on_move_completed_instance(instance : EffectInstance):
	for function in on_move_completed:
		if function == null : continue;
		function.execute(instance);


func on_turn_end_instance(instance : EffectInstance):
	for function in on_turn_end:
		if function == null : continue;
		function.execute(instance);
