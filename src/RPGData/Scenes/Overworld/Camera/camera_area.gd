extends Node2D

var _current_area : Area2D;
var _current_shape : CollisionShape2D;
var _set_camera : bool = false;

func _physics_process(delta: float) :
	if !_set_camera && _current_area != null && _current_shape != null :
		var shape_pos = _current_shape.global_position;
		var shape = _current_shape.shape;
		
		var shape_top = shape_pos.y + (shape.size.y * 0.5)
		var shape_bottom = shape_pos.y - (shape.size.y * 0.5)
		var shape_left = shape_pos.x - (shape.size.x * 0.5)
		var shape_right = shape_pos.x + (shape.size.x * 0.5)
		
		var area_pos = $Collision/CollisionShape2D.global_position;
		var area_bounds = $Collision/CollisionShape2D.shape;
		
		var area_top = area_pos.y + (area_bounds.size.y * 0.5)
		var area_bottom = area_pos.y - (area_bounds.size.y * 0.5)
		var area_left = area_pos.x - (area_bounds.size.x * 0.5)
		var area_right = area_pos.x + (area_bounds.size.x * 0.5)
		
		if shape_top <= area_top && shape_bottom >= area_bottom && shape_left >= area_left && shape_right <= area_right :
			_set_camera = true;
			OverworldManager.game_camera.follow_damping = false;
			OverworldManager.game_camera.limit_target = OverworldManager.game_camera.get_path_to($Collision/CollisionShape2D)
			await get_tree().physics_frame;
			OverworldManager.game_camera.follow_damping = true;
			print("Setting to..." + name)


func _on_area_entered(area: Area2D) :
	if !(area.get_parent() is RPGPlayerController) : return;
	
	while (OverworldManager.game_camera == null) :
		await get_tree().process_frame;
	
	_current_area = area;
	_current_shape = area.get_child(0);
	_set_camera = false;


func _on_area_exited(area: Area2D) :
	if !(area.get_parent() is RPGPlayerController) : return;
	
	_current_area = null;
	_current_shape = null;
	_set_camera = false;
