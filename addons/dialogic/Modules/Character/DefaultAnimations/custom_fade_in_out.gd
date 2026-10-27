extends DialogicAnimation

func animate() -> void:

	var modulation_property := get_modulation_property()
	var end_modulation := Color.WHITE;
	
	var offset_property := "shader_parameter/shadow_offset";
	var end_offset := Vector2(20.0, 0.0);

	if is_reversed:
		end_modulation = Color(0,0,0,0);
		end_offset = Vector2(0.0, 0.0);

	else:
		var original_modulation := Color(0,0,0,0)
		node.set(modulation_property, original_modulation)
		
		var help = node.get_child(0);
		print("PLEASE: " + help.name)
		
		node.get_child(0).get_child(0).material.set_shader_parameter("shadow_offset", Vector2(0.0, 0.0));

	var tween := (node.create_tween() as Tween)
	if is_reversed:
		tween.set_ease(Tween.EASE_IN)
	else:
		tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel(true);
	
	tween.tween_property(node.get_child(0).get_child(0).material, offset_property, end_offset, time)
	tween.tween_property(node, modulation_property, end_modulation, time)

	await tween.finished
	finished_once.emit()


func _get_named_variations() -> Dictionary:
	return {
		"custom fade in": {"reversed": false, "type": AnimationType.IN},
		"custom fade out": {"reversed": true, "type": AnimationType.OUT},
		"custom fade cross": {"type": AnimationType.CROSSFADE},
	}
