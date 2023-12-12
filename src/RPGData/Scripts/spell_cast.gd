extends Object
class_name SpellCast

# SpellCast is a class that represents the result of a spell use.

var success : bool = false;
var spell : Spell;
var user : EntityController;
var target : EntityController;

var damage : Array[int];
var total_damage : int;
var hits : Array[bool];
var critical : bool
var critical_hits : Array[bool];

# Used for animation processing in the original game. Not sure if needed.
var current_hit : int;

# Dialogue
var fail_message : String;

# TODO: Effects

func _init():
	print("Init SpellCast");


# Spell Cast Operations
func set_damage(dm : Array[int]):
	damage = dm;
	
	for i in damage.size():
		total_damage += damage[i];
		# TODO: Do effect rolls


func set_critical(crt : Array[bool]):
	critical_hits = crt;
	
	for i in critical_hits.size():
		if critical_hits[i]:
			critical = true;


func set_hits(hit : Array[bool]):
	hits = hit;


# General Spell Checks and Accessors
func has_spell_done_anything() -> bool:
	# TODO: Check if effect was activated
	return !(total_damage == 0 && (hits == null || (hits != null && hits.size() == 0)));


func get_damage_index(index : int) -> int:
	if damage == null || index >= damage.size():
		return 0;
	
	return damage[index];


func get_damage_applied() -> int:
	
	if damage == null || damage.size() == 0 || target == null:
		return 0;
	
	var result = 0;
	
	for i in damage.size():
		
		if result + damage[i] < target.current_hp:
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
	return damage[current_hit];


func get_current_hit_success() -> bool:
	return hits[current_hit];


func get_current_hit_critical() -> bool:
	return critical_hits[current_hit];


func get_previous_hit_damage() -> int:
	if current_hit == 0:
		return 0;
	
	return damage[current_hit - 1];


func increment_hit():
	current_hit += 1;


# TODO: Spell Dialogue Functions (Might move these elsewhere?)
