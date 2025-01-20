extends CanvasLayer

@export var fade_sequence : TweenPlayer;
@export var camera_fade_sequence : TweenPlayer;

func _ready():
	self.visible = true;
	EventManager.battle_fade_start.connect(_fade_action);


func _fade_action(fade_in : bool):
	if fade_sequence != null:
		if fade_in:
			fade_sequence.play_tween_name("Fade In");
			camera_fade_sequence.play_tween_name("Transition Zoom In");
		else:
			fade_sequence.play_tween_name("Fade Out");
		await fade_sequence.tween_ended;
	
	EventManager.battle_fade_completed.emit(fade_in);


func _on_destroy():
	if EventManager != null:
		EventManager.battle_fade_start.disconnect(_fade_action);
