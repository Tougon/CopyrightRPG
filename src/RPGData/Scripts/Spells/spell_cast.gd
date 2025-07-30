extends Object
class_name SpellCast

# SpellCast is a class that represents the result of a spell use.

enum SpellFailType { InvalidMP, InvalidCast, Miss, NoEffect }

var success : bool = false;
var spell : Spell;
var user : EntityController;
var target : EntityController;

var damage : Array[int];
var total_damage : int;
var hits : Array[bool];
var hit_results : Array[String];
var critical : bool
var critical_hits : Array[bool];

# Indicates if the parent damage function was called.
# This is effectively a "no effect" spell but is otherwise undetectable as such.
var base_damage_cast : bool = false;

# Random per hit variables
var target_index_override : Array[int];

# Used for animation processing.
var current_hit : int;

# Dialogue
var fail_type : SpellFailType;
var fail_message : String;

var effects : Array[EffectInstance];
var subspell_casts : Array[SpellCast];

func _init():
	pass;


# Spell Cast Operations
func set_damage(dm : Array[int]):
	damage = dm;


func check_for_effect(effect : Effect) -> bool:
	for eff in effects:
		if eff.effect == effect:
			return true;
	return false;


func set_critical(crt : Array[bool]):
	critical_hits = crt;
	
	for i in critical_hits.size():
		if critical_hits[i]:
			critical = true;


func set_hits(hit : Array[bool]):
	hits = hit;
	
	for i in hits.size():
		
		if spell != null && hits[i] == true:
			for n in spell.effects_on_hit.size():
				var eff = spell.effects_on_hit[n].get_effect(user.param.entity_luck);
				var proc = randf();
				
				var luck = 1;
				
				if spell.effects_on_hit[n].use_luck :
					luck = user.param.entity_luck;
				
				if proc <= (spell.effects_on_hit[n].chance * luck) && eff != null:
					var exists = check_for_effect(eff)
					
					if !exists || (exists && eff.stackable):
						var inst = eff.create_effect_instance(user, target, self);
						inst.check_success();
						effects.append(inst);


func add_hit_result(result : String):
	hit_results.append(result);


func clear_hit_result():
	for i in hit_results.size():
		hit_results[i] = "";


# General Spell Checks and Accessors
func has_spell_done_anything() -> bool:
	return !(total_damage == 0 && !get_effect_proc() && (hits == null || (hits != null && (hits.size() == 0 || base_damage_cast))));


func get_effect_proc() -> bool:
	for effect in effects:
		if effect.cast_success :
			return true;
	return false;


func get_damage_index(index : int) -> int:
	if damage == null || index >= damage.size():
		return 0;
	
	return damage[index];


func get_damage_applied() -> int:
	
	if damage == null || damage.size() == 0 || target == null:
		return 0;
	
	var result = 0;
	
	for i in damage.size():
		
		if result + damage[i] > target.current_hp:
			return target.current_hp;
		
		result += damage[i];
	
	return result;


func get_hit_success(index : int) -> bool:
	if hits == null || index >= hits.size():
		return false;
	return hits[index];


func did_spell_hit() -> bool:
	if hits == null:
		return false;
	
	for hit in hits:
		if hit:
			return true;
	
	return false;


func get_number_of_hits() -> int:
	if damage == null : 
		return 0;
	return damage.size();


#  Current Hit Operations
func get_current_hit_damage() -> int:
	if current_hit >= damage.size() : return 0;
	return damage[current_hit];


func get_current_hit_success() -> bool:
	if current_hit >= hits.size() : return false;
	return hits[current_hit];


func get_current_hit_critical() -> bool:
	if current_hit >= critical_hits.size() : return false;
	return critical_hits[current_hit];


func get_previous_hit_damage() -> int:
	if current_hit == 0:
		return 0;
	
	return damage[current_hit - 1];


func increment_hit():
	current_hit += 1;
