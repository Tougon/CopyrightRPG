extends Control

@export var label_key : String;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/Label.text = label_key;


func set_stat_value(value : int, modifier : int = 0):
	if modifier == 0 :
		$HBoxContainer/Value.text = str(value);
	else :
		if modifier > 0 : 
			$HBoxContainer/Value.text = str(value) + " [color=#3ce864]+ " + str(modifier) + "[/color]";
		else:
			$HBoxContainer/Value.text = str(value) + " [color=#ed3b3e]- " + str(abs(modifier)) + "[/color]";
