extends Resource
class_name Encounter;

@export var enemy_ids : Array[int];
@export_range(0, 1) var odds : float;
@export var can_flee : bool = true;
@export var ignore_flee_mechanics : bool = false;
