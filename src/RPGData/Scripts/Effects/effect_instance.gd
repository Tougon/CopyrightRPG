extends Node
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


func check_success():
	pass;
