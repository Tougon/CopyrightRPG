extends Sprite2D

signal sprite_clicked();

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var point = to_local(event.position);
		if get_rect().has_point(point):
			if is_pixel_opaque(point):
				sprite_clicked.emit();
