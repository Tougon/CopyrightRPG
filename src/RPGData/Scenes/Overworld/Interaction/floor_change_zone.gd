extends Node2D

@onready var start_point : Node2D = $Start;
@onready var end_point : Node2D = $End;

var in_bounds : Array[RPGCharacter];


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;
	#_on_player_enter_floor_change_zone(DataManager.current_save.player_floor_change);
	#EventManager.on_player_enter_floor_change_zone.connect(_on_player_enter_floor_change_zone);


func _process(delta: float) -> void:
	for body in in_bounds:
		if body != null :
			var percent = _get_position_percentage(body);
			
			var offset = end_point.global_position.y - start_point.global_position.y;
			body.position.y = percent * offset;
			
			


func _get_position_percentage(body : Node2D) -> float:
	var pos = body.get_parent().global_position.x;
	var start_pos = start_point.global_position.x;
	var end_pos = end_point.global_position.x;
	
	if (pos < start_pos && pos > end_pos) || (pos > start_pos && pos < end_pos) :
		var dist = abs(end_pos - start_pos);
		var progress = abs(end_pos - pos);
		return 1.0 - lerpf(0.0, 1.0, progress / dist);
	else :
		var dist_in = abs(pos - start_pos);
		var dist_out = abs(pos - end_pos);
		
		if dist_in < dist_out : 
			return 0.0;
		else : 
			return 1.0;


func _on_body_entered(body: Node2D) -> void:
	if !can_process() : return;
	
	if body is RPGPlayerController :
		in_bounds.append(body._player_visual)
	if body is RPGOverworldFollower :
		in_bounds.append(body._player_visual)
	
	var pos = body.global_position;
	
	var dist_in = pos.distance_squared_to(start_point.global_position);
	var dist_out = pos.distance_squared_to(end_point.global_position);
	
	#EventManager.on_player_enter_floor_change_zone.emit(true);


func _on_body_exited(body: Node2D) -> void:
	if body is RPGPlayerController :
		if body._player_visual != null :
			in_bounds.erase(body._player_visual);
			body._player_visual.position.y = 0;
	if body is RPGOverworldFollower :
		if body._player_visual != null : 
			in_bounds.erase(body._player_visual);
			body._player_visual.position.y = 0;


func _on_player_enter_floor_change_zone(enter : bool) :
	pass;
	#for object in in_objects:
	#	if object == null : continue;
	#	
	#	object.visible = enter;
	#	if enter : object.process_mode = ProcessMode.PROCESS_MODE_INHERIT;
	#	else : object.process_mode = ProcessMode.PROCESS_MODE_DISABLED;
	
	#for object in out_objects:
	#	if object == null : continue;
	#	
	#	object.visible = !enter;
	#	if enter : object.process_mode = ProcessMode.PROCESS_MODE_DISABLED;
	#	else : object.process_mode = ProcessMode.PROCESS_MODE_INHERIT;


func _exit_tree() :
	pass;
	#if EventManager != null :
	#	EventManager.on_player_enter_floor_change_zone.disconnect(_on_player_enter_floor_change_zone);
