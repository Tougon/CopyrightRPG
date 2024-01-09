extends Object

class_name TweenExtensions


static func shake_position_2d(node : Node, duration : float, vibration_speed : float, strength : Vector2, transition_type : Tween.TransitionType = Tween.TRANS_SINE, ease_type : Tween.EaseType = Tween.EASE_IN, decay_factor : float = 0.66, randomize_start : bool = false):
	
	if vibration_speed == 0: return;
	
	var direction : Vector2;
	
	if randomize_start :
		if randf() > 0.5:
			direction.x = 1;
		else:
			direction.x = -1;
		if randf() > 0.5:
			direction.y = 1;
		else:
			direction.y = -1;
	else:
		if strength.x >= 0:
			direction.x = 1;
		else:
			direction.x = -1;
		if strength.y >= 0:
			direction.y = 1;
		else:
			direction.y = -1;
	
	strength = strength.abs();
	
	var original_position = node.position;
	
	if decay_factor >= 1:
		decay_factor = 0.9999;
	
	var time : float = 0.0;
	var step : float = 1.0 / vibration_speed;
	
	var iterations = 0;
	
	while time < duration:
		var tween = _move_in_direction(node, direction, strength, step, transition_type, ease_type)
		time += step * 4;
		
		await tween.finished;
		
		direction *= -1;
		iterations += 1;
		strength *= decay_factor;
		
	node.position = original_position;
	print(iterations)
	print(step)


static func _move_in_direction(node : Node, direction : Vector2, strength : Vector2, step : float, transition : Tween.TransitionType, ease : Tween.EaseType) -> Tween:
	
	var tween = node.get_tree().create_tween();
	tween.set_parallel(false);
	
	var pos_in = tween.tween_property(node, "position", direction * strength, step);
	pos_in.as_relative();
	pos_in.set_trans(transition)
	pos_in.set_ease(ease);
	
	var pos_out = tween.tween_property(node, "position", -direction * strength, step);
	pos_out.as_relative();
	pos_out.set_trans(transition)
	pos_out.set_ease(ease);
	
	var pos_rev_out = tween.tween_property(node, "position", -direction * strength, step);
	pos_rev_out.as_relative();
	pos_rev_out.set_trans(transition)
	pos_rev_out.set_ease(ease);
	
	var pos_rev_in = tween.tween_property(node, "position", direction * strength, step);
	pos_rev_in.as_relative();
	pos_rev_in.set_trans(transition)
	pos_rev_in.set_ease(ease);
	
	return tween;
