# This script should be referenced as needed, then deleted.
extends Node

@export var floor_one : TileMapLayer;
@export var floor_two : TileMapLayer;
var current_floor : int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	floor_two.modulate = Color(1,1,1,0);


func _unhandled_input(event):
	if event.is_pressed() && event is InputEventKey:
		var key_event = event as InputEventKey;
		
		if key_event.keycode == KEY_SPACE:
			var tween = get_tree().create_tween();
			
			if current_floor == 0 : 
				current_floor = 1;
				tween.tween_property(floor_two, "modulate", Color.WHITE, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			else:
				current_floor = 0;
				tween.tween_property(floor_two, "modulate", Color(1,1,1,0), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
