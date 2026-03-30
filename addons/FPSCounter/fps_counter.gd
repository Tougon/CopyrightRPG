extends Control

@onready var label : Label = $Label;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var framerate = Engine.get_frames_per_second();
	label.text = str(framerate);
	
	if framerate < 30 : 
		modulate = Color.RED;
	elif framerate < 60 : 
		modulate = Color.YELLOW;
	else : 
		modulate = Color.GREEN;
