extends CanvasLayer

@export var fade_sequence : TweenPlayer;

# TODO: This currently makes no distinction about the enemies
# We will eventually want different animations for bosses and the like
func _ready():
	EventManager.overworld_battle_fade_start.connect(_fade_action);


func _fade_action(fade_in : bool):
	if fade_sequence != null:
		if fade_in:
			fade_sequence.play_tween_name("Fade In");
		else:
			fade_sequence.play_tween_name("Fade Out");
		await fade_sequence.tween_ended;
	
	EventManager.overworld_battle_fade_completed.emit(fade_in);
	
	if fade_sequence != null:
		fade_sequence.play_tween_name("Fade Complete");


func _on_destroy():
	if EventManager != null:
		EventManager.overworld_battle_fade_start.disconnect(_fade_action);
