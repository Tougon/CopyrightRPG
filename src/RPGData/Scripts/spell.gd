@tool
extends Resource
class_name Spell


const SEAL_COST_MULTIPLIER : float = 1.5;
# Temp value used to fix damage calculation at 50
const DAMAGE_CONSTANT : int = 50;

enum SpellType { Other, Attack, Status, Buff, Debuff, Heal }
enum SpellTarget { SingleEnemy, RandomEnemy, AllEnemy, Self, SingleParty, AllParty, All }

@export_group("Universal Spell Parameters")
@export_subgroup("Spell Naming")
@export var spell_name_key : String;
@export var spell_description_key : String;
@export var spell_cast_message_key : String;
var spell_fail_message_key : String;

@export_subgroup("Spell Core")
@export var spell_type : SpellType;
@export var spell_target : SpellTarget;
@export var spell_cost : int;
@export var spell_priority : int;
@export var spell_flags : Array[TFlag];

# TODO: Remake the animation component

# TODO: add support for effects
#@export_subgroup("Spell Effects")
# On Hit
# On Success
# Properties
