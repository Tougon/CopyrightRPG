extends Node2D

@onready var start : Node2D = $Start;
@onready var end : Node2D = $End;
@export_range(-9,9) var start_floor : int = 0;
@export_range(-9,9) var end_floor : int = 0;

func _on_body_exited(body: Node2D) -> void:
	var pos = body.global_position;
	
	var dist_start = pos.distance_squared_to(start.global_position);
	var dist_end = pos.distance_squared_to(end.global_position);
	
	if dist_end < dist_start :
		EventManager.on_overworld_change_floor.emit(end_floor);
	else :
		EventManager.on_overworld_change_floor.emit(start_floor);
