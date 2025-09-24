extends Node2D

var _current_area : Area2D;
var _current_shape : CollisionShape2D;
var _set_camera : bool = false;

@export var limit_vertical : bool = false;
@export var limit_horizontal : bool = false;


func _process(delta: float) :
	if !_set_camera && _current_area != null && _current_shape != null :
		_set_camera_limit();


func _set_camera_limit() :
	var shape_pos = _current_shape.global_position;
	var shape = _current_shape.shape;
	
	var shape_top = shape_pos.y + (shape.size.y * 0.5)
	var shape_bottom = shape_pos.y - (shape.size.y * 0.5)
	var shape_left = shape_pos.x - (shape.size.x * 0.5)
	var shape_right = shape_pos.x + (shape.size.x * 0.5)
	
	var area_pos = $Collision/CollisionShape2D.global_position;
	var area_bounds = $Collision/CollisionShape2D.shape;
	
	var area_top = area_pos.y - (area_bounds.size.y * 0.5)
	var area_bottom = area_pos.y + (area_bounds.size.y * 0.5)
	var area_left = area_pos.x - (area_bounds.size.x * 0.5)
	var area_right = area_pos.x + (area_bounds.size.x * 0.5)
	
	if shape_top >= area_top && shape_bottom <= area_bottom && shape_left >= area_left && shape_right <= area_right :
		_set_camera = true;
		var should_tween = true;
		
		if str(OverworldManager.game_camera.limit_target).length() > 0 : 
			#print("Previously bound to " + str(OverworldManager.game_camera.limit_target))
			should_tween = false;
		
		OverworldManager.game_camera.limit_target = "";
		
		if !limit_horizontal :
			area_left = -10000000;
			area_right = 10000000;
		
		if !limit_vertical :
			area_top = -10000000;
			area_bottom = 10000000;
		
		if should_tween :
			var tween = get_tree().create_tween();
			tween.set_parallel(true);
			tween.tween_property(OverworldManager.game_camera, "limit_left", area_left, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
			tween.tween_property(OverworldManager.game_camera, "limit_right", area_right, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
			tween.tween_property(OverworldManager.game_camera, "limit_top", area_top, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
			tween.tween_property(OverworldManager.game_camera, "limit_bottom", area_bottom, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
		else :
			OverworldManager.game_camera.limit_left = area_left;
			OverworldManager.game_camera.limit_right = area_right;
			OverworldManager.game_camera.limit_top = area_top;
			OverworldManager.game_camera.limit_bottom = area_bottom;
			OverworldManager.game_camera.teleport_position();


func _on_area_entered(area: Area2D) :
	if !OverworldManager.ALLOW_CAMERA_LOCK : return;
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
