extends Resource

class_name TweenGroup

@export var frames: Array[TweenFrame]	


func get_longest_tween_index():
	var result: int = 0;
	var duration: float = 0;
	
	for i in frames.size():
		
		if frames[i].duration + frames[i].delay > duration:
			duration = frames[i].duration + frames[i].delay;
			result = i;
	
	return result;


func get_longest_tween_duration():
	var duration: float = 0;
	
	for i in frames.size():
		
		if frames[i].duration + frames[i].delay > duration:
			duration = frames[i].duration + frames[i].delay;
	
	return duration;
