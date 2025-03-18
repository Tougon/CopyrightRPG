extends Control

@export var label_key : String;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/Label.text = label_key;


func set_stat_value(value : int):
	$HBoxContainer/Value.text = str(value);
