extends Control

@export var dialogue_canvas : DialogueCanvas;
@export var offset : Vector2;

func _ready():
	dialogue_canvas.on_set_dialogue_end_pos.connect(_set_icon_position);


func _set_icon_position(pos : Vector2):
	print(pos);
	print((pos.x - position.x));
	position = pos;


func _on_destroy():
	if dialogue_canvas != null : 
		dialogue_canvas.on_set_dialogue_end_pos.disconnect(_set_icon_position);
