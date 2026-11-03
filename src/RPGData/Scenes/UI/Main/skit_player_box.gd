extends Control

@export var border_color_default : Color;
@export var border_color_speaking : Color;
@export var bg_color_default : Color;
@export var bg_color_speaking : Color;
@export var portrait_color_default : Color;
@export var portrait_color_speaking : Color;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Border.modulate = border_color_default;
	#scale = Vector2.ONE * 0.9;
