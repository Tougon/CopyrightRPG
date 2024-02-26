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
var spell_override : Spell;

func get_effect_name() -> String:
	return effect.get_effect_name(self);

func check_success():
	pass;

func on_activate():
	effect.on_activate_instance(self);

func on_failed_to_activate():
	effect.on_failed_to_activate_instance(self);
