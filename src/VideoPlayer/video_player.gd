extends VideoStreamPlayer
class_name LoopingVideoPlayer

@export var delay_start : bool = false;
@export var delay_time : float = 0.1;

# Called when the node enters the scene tree for the first time.
func _ready():
	finished.connect(on_finished);
	
	if autoplay : play_video();


func play_video():
	if delay_start : await get_tree().create_timer(delay_time).timeout
	play();


func play_video_at(time : float):
	play();
	
	while time > get_stream_length() && get_stream_length() > 0:
		time -= get_stream_length();
	
	if time < 0 : time += get_stream_length();
	
	stream_position = time;


func on_finished():
	play();


func _on_destroy():
	finished.disconnect(on_finished);
