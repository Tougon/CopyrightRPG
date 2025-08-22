@tool
extends DamageSpell
class_name InfiniteLoopSpell

@export_group("Loop Parameters")
@export var accuracy_drop_per_hit : float = 5;
@export var use_num_hits_for_drop : bool = false;
@export var min_accuracy : int = 25;
@export var max_accuracy : int = 100;
@export var hit_limit : int = 100;


func calculate_damage(user : EntityController, target : EntityController, cast : SpellCast):
	var num_hits = 5;
	
	var result : Array[int];
	var crit : Array[bool];
	var hit : Array[bool];
	var index : Array[int];
	var power : float = check_spell_power(user, target);
	var i = 0;
	
	spell_accuracy_per_hit = spell_accuracy;
	
	while hit.size() < hit_limit :
		_damage_loop(power, user, target, cast, result, crit, hit, index, i);
		
		if !hit[i] : 
			break;
		
		i += 1;
		
		if use_num_hits_for_drop : 
			spell_accuracy_per_hit -= accuracy_drop_per_hit * i;
		else : 
			spell_accuracy_per_hit -= accuracy_drop_per_hit;
		
		if spell_accuracy_per_hit < min_accuracy :
			spell_accuracy_per_hit = min_accuracy;
		if spell_accuracy_per_hit > max_accuracy :
			spell_accuracy_per_hit = max_accuracy;
	
	cast.set_damage(result);
	cast.set_hits(hit);
	cast.set_critical(crit);
	cast.target_index_override = index;
