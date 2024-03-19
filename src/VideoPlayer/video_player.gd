extends VideoStreamPlayer
class_name LoopingVideoPlayer

@export var delay_start : bool = false;
@export var delay_time : float = 0.1;

# Called when the node enters the scene tree for the first time.
func _ready():
	finished.connect(on_finished);
	
	if delay_start : await get_tree().create_timer(delay_time).timeout
	play();


func on_finished():
	play();


func _on_destroy():
	finished.disconnect(on_finished);
