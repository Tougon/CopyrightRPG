extends Node2D

@onready var start : Node2D = $Start;
@onready var end : Node2D = $End;
@export_range(-9,9) var start_floor : int = 0;
@export_range(-9,9) var end_floor : int = 0;
@export var teleport : bool = false;
@export var teleport_target : Node2D;

var _can_collide : bool = true;

func _on_body_exited(body: Node2D) -> void:
	if !_can_collide || !can_process() : return;
	#if body is RPGPlayerController && body._exiting : 
	#	print("FYUCK!")
	#	return;
	
	_can_collide = false;
	
	print(name);
	var pos = body.global_position;
	
	var dist_start = pos.distance_squared_to(start.global_position);
	var dist_end = pos.distance_squared_to(end.global_position);
	
	if dist_end < dist_start :
		EventManager.on_overworld_change_floor.emit(end_floor, teleport, teleport_target.global_position);
	else :
		EventManager.on_overworld_change_floor.emit(start_floor, teleport, teleport_target.global_position);
	
	await get_tree().process_frame;
	_can_collide = true;


func _exit_tree():
	_can_collide = false;
