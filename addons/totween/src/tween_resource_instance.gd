extends Resource

class_name TweenResourceInstance

@export var tween_name: String;
@export var tween_resource: TweenResource;
@export var play_on_start: bool = false;
@export var next_tween: String;

func _init(p_tween_name = ""):
	tween_name = p_tween_name;
