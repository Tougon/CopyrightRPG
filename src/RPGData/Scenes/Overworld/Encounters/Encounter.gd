extends Resource
class_name Encounter;

@export var primary_enemy : int;
@export_range(0, 1) var odds : float;
@export var can_flee : bool = true;
@export var ignore_flee_mechanics : bool = false;

@export_range(0, 9) var min_enemies : int = 1;
@export_range(0, 9) var max_enemies : int = 3;
@export var enemy_count_curve : Curve;

@export var required_enemies : Array[int];
@export var additional_enemies : Array[int];
@export var additional_enemy_curve : Curve;


func get_encounter_enemies() -> Array[int] :
	var result : Array[int];
	result.append(primary_enemy);
	
	if required_enemies != null && required_enemies.size() > 0 :
		result.append_array(required_enemies);
	
	var num_enemies_seed = enemy_count_curve.sample(randf());
	var num_enemies = roundi(lerpf(min_enemies as float, max_enemies as float, num_enemies_seed));
	
	for i in num_enemies :
		var enemy_seed = 0;
		if additional_enemy_curve != null :
			enemy_seed = additional_enemy_curve.sample(randf());
		
		var enemy_index = roundi(lerpf(0 as float, (additional_enemies.size() - 1) as float, enemy_seed));
		
		if enemy_index < additional_enemies.size() && enemy_index >= 0:
			result.append(additional_enemies[enemy_index]);
		else :
			result.append(primary_enemy);
	
	return result;
