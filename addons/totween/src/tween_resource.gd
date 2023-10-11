extends Resource

class_name TweenResource

@export var tween_name: String;
@export var sequence: Array[TweenGroup];

func _init(p_tween_name = ""):
	tween_name = p_tween_name;
