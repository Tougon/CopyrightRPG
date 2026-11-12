extends DialogicAnimation

func animate() -> void:
	var modulation_property := get_modulation_property()
	
	node.set(modulation_property, Color.WHITE)
	node.get_child(0).get_child(0).material.set_shader_parameter("shadow_offset", Vector2(0.0, 0.0));
	
	await node.get_tree().process_frame
	finished.emit()


func _get_named_variations() -> Dictionary:
	return {
		"instant in": {"reversed": false, "type": AnimationType.IN},
		"instant out": {"reversed": true, "type": AnimationType.OUT},
	}
