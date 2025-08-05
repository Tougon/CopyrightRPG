extends Object
class_name EffectInstance

var turns_active : int = 0;
var turn_limit : int = 0;

var strength : int = 0;

var cast_success : bool = false;

var effect : Effect;
var user : EntityController;
var target : EntityController;

var spell : SpellCast;
var all_casts : Array[SpellCast];
var spell_data : Spell
var spell_override : Spell;

# Arbitrary cached data
var data : Dictionary;

func get_effect_name() -> String:
	return effect.get_effect_name(self);

func check_success():
	effect.check_for_cast_success(self);

func check_remain_active():
	effect.check_for_remain_active(self);

func on_activate():
	effect.on_activate_instance(self);

func on_failed_to_activate():
	effect.on_failed_to_activate_instance(self);

func on_apply():
	effect.on_apply_instance(self);

func on_stack():
	effect.on_stack_instance(self);

func on_deactivate():
	effect.on_deactivate_instance(self);

func on_turn_start():
	effect.on_turn_start_instance(self);

func on_move_selected():
	effect.on_move_selected_instance(self);

func on_move_completed():
	effect.on_move_completed_instance(self);

func on_turn_end():
	effect.on_turn_end_instance(self);
