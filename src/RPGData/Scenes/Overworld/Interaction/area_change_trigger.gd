extends Node2D

@onready var start : Node2D = $Start;
@onready var end : Node2D = $End;
@export var start_area : String = "";
@export var end_area : String = "";

var _can_collide : bool = true;

func _on_body_exited(body: Node2D) -> void:
	if !_can_collide || !can_process() : return;
	if body is RPGPlayerController && body._exiting : return;
	
	_can_collide = false;
	#print(name);
	var pos = body.global_position;
	var teleport_pos = global_position;
	
	var dist_start = pos.distance_squared_to(start.global_position);
	var dist_end = pos.distance_squared_to(end.global_position);
	
	if dist_end < dist_start :
		EventManager.on_overworld_change_area.emit(end_area);
	else :
		EventManager.on_overworld_change_area.emit(start_area);
	
	await get_tree().process_frame;
	_can_collide = true;


func _exit_tree():
	_can_collide = false;
