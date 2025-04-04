extends Resource
class_name SealEffectGroup

@export var override_turn_count : bool;
@export_range(1, 10) var turn_count : int = 1;
@export var seal_effects : Array[Effect];
