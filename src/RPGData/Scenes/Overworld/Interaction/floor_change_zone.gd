extends Node2D

@onready var in_point : Node2D = $In;
@onready var out_point : Node2D = $Out;

@export var in_objects : Array[Node2D];
@export var out_objects : Array[Node2D];


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODOGAME: Cache state?
	_on_player_enter_floor_change_zone(false);
	EventManager.on_player_enter_floor_change_zone.connect(_on_player_enter_floor_change_zone);


func _on_body_entered(body: Node2D) -> void:
	var pos = body.global_position;
	
	var dist_in = pos.distance_squared_to(in_point.global_position);
	var dist_out = pos.distance_squared_to(out_point.global_position);
	
	EventManager.on_player_enter_floor_change_zone.emit(dist_in < dist_out);


func _on_body_exited(body: Node2D) -> void:
	var pos = body.global_position;
	
	var dist_in = pos.distance_squared_to(in_point.global_position);
	var dist_out = pos.distance_squared_to(out_point.global_position);
	
	EventManager.on_player_enter_floor_change_zone.emit(dist_in < dist_out);


func _on_player_enter_floor_change_zone(enter : bool) :
	for object in in_objects:
		object.visible = enter;
		if enter : object.process_mode = ProcessMode.PROCESS_MODE_INHERIT;
		else : object.process_mode = ProcessMode.PROCESS_MODE_DISABLED;
	
	for object in out_objects:
		object.visible = !enter;
		if enter : object.process_mode = ProcessMode.PROCESS_MODE_DISABLED;
		else : object.process_mode = ProcessMode.PROCESS_MODE_INHERIT;


func _exit_tree() :
	if EventManager != null :
		EventManager.on_player_enter_floor_change_zone.disconnect(_on_player_enter_floor_change_zone);
