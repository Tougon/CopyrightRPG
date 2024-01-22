@tool
extends Resource
class_name Spell


const SEAL_COST_MULTIPLIER : float = 1.5;
# Temp value used to fix damage calculation at 50
const DAMAGE_CONSTANT : int = 50;

enum SpellType { Other, Attack, Status, Buff, Debuff, Heal, Flavor }
enum SpellTarget { SingleEnemy, RandomEnemy, RandomEnemyPerHit, AllEnemy, Self, SingleParty, AllParty, All }

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

@export_subgroup("Spell Animation")
@export var animation_sequence : AnimationSequenceObject;

var fail_message : String = "";

# TODO: add support for effects
#@export_subgroup("Spell Effects")
# On Hit
# On Success
# Properties


# Returns an instance of this spell using the spell data to calculate everything
func cast(user : EntityController, targets : Array[EntityController]):
	var result : Array[SpellCast] = [];
	
	var mp_check = check_mp(user);
	
	for target in targets:
		var cast = SpellCast.new();
		cast.spell = self;
		cast.user = user;
		cast.target = target;
		
		cast.success = mp_check;
		
		if cast.success:
			# TODO: Implement actual checks for the below
			cast.success = check_can_cast(user, target);
			
			if cast.success:
				# TODO: Apply spell properties.
				# These may affect any calculation going forward.
				
				# TODO: Implement accuracy check
				cast.success = check_spell_hit(user, target);
				
				if cast.success:
					calculate_damage(user, target, cast);
					
					if spell_type == SpellType.Flavor:
						cast.success = true;
					else:
						cast.success = cast.has_spell_done_anything();
				
				# TODO: Deactivate properties
		else:
			cast.fail_message = tr("T_BATTLE_MP_BAD").format({entity = user.param.entity_name});
		result.append(cast);
	
	return result;


func check_mp(user : EntityController) -> bool:
	var cost = spell_cost;
	# TODO: Subtract more MP if sealing
	
	var result = user.current_mp >= cost;
	
	if result:
		user.modify_mp(cost);
	
	return result;


func check_can_cast(user : EntityController, target : EntityController):
	return true;


func check_spell_hit(user : EntityController, target : EntityController, amt : float = -1):
	return true;


func calculate_damage(user : EntityController, target : EntityController, cast : SpellCast):
	cast.set_damage([0]);
	cast.set_hits([true]);
	cast.set_critical([false]);
