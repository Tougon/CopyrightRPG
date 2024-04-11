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

# Runtime Values
var fail_message : String = "";
var cached_targets : Array[EntityController];

@export_subgroup("Spell Effects")
@export var effects_on_hit : Array[EffectSetChance]
@export var effects_on_success : Array[EffectSetChance]
@export var properties : Array[Effect]
# Properties


# Returns an instance of this spell using the spell data to calculate everything
func cast(user : EntityController, targets : Array[EntityController]):
	cached_targets = targets;
	var result : Array[SpellCast] = [];
	
	var mp_check = check_mp(user);
	
	if spell_target != SpellTarget.RandomEnemyPerHit:
		for target in targets :
			_cast(user, target, result, mp_check);
	else :
		var rand_index = randi_range(0, targets.size() - 1);
		var target = targets[rand_index];
		_cast(user, target, result, mp_check);
	
	return result;


func _cast(user : EntityController, target : EntityController, result : Array[SpellCast], mp_check : bool):
	var cast = SpellCast.new();
	cast.spell = self;
	cast.user = user;
	cast.target = target;
	
	cast.success = mp_check;
	
	if cast.success:
		# TODO: Implement actual checks for the below
		cast.success = check_can_cast(user, target);
		
		if cast.success:
			# Apply spell properties.
			var prop_instances : Array[EffectInstance];
			
			for e in properties:
				if !_check_is_property_in_list(prop_instances, e):
					var eff = e.create_effect_instance(user, target, cast);
					eff.check_success();
					if eff.cast_success: 
						eff.on_activate();
						prop_instances.append(eff);
			
			var user_prop_instances = user.properties;
			
			for e in user_prop_instances:
				e.check_success();
				
				if e.cast_success: 
					e.on_activate();
			
			# TODO: Implement accuracy check
			cast.success = check_spell_hit(user, target);
			
			if cast.success:
				calculate_damage(user, target, cast);
				
				if spell_type == SpellType.Flavor:
					cast.success = true;
				else:
					cast.success = cast.has_spell_done_anything();
			else :
				cast.set_hits([false]);
				cast.set_damage([0])
				cast.set_critical([false])
			
			# Deactivate properties
			for p in prop_instances:
				p.on_deactivate();
			
			user.clear_properties();
	else:
		cast.fail_message = tr("T_BATTLE_MP_BAD").format({entity = user.param.entity_name});
	result.append(cast);


func _check_is_property_in_list(props : Array[EffectInstance], eff : Effect) -> bool:
	for p in props:
		if p.effect == eff && !eff.stackable:
			return true;
	
	return false;


func check_mp(user : EntityController) -> bool:
	var cost = spell_cost;
	# TODO: Subtract more MP if sealing
	
	var result = user.current_mp >= cost;
	
	if result:
		user.modify_mp(-cost);
	
	return result;


func check_can_cast(user : EntityController, target : EntityController):
	return true;


func check_spell_hit(user : EntityController, target : EntityController, amt : float = -1):
	return true;


func calculate_damage(user : EntityController, target : EntityController, cast : SpellCast):
	cast.set_damage([0]);
	cast.set_hits([true]);
	cast.set_critical([false]);
