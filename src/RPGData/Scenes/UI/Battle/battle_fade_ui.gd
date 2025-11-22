extends CanvasLayer

@export var fade_in_player : TweenPlayer;
@export var fade_out_player : TweenPlayer;
@export var camera_fade_player : TweenPlayer;

func _ready():
	self.visible = true;
	EventManager.battle_fade_start.connect(_fade_action);


func _fade_action(fade_in : bool):
	if fade_in_player : fade_in_player.get_parent().visible = fade_in;
	if fade_out_player : fade_out_player.get_parent().visible = !fade_in;
	
	if fade_in:
		AudioManager.play_sfx("battle_in")
		
		if camera_fade_player != null :
			camera_fade_player.play_tween_name("Transition Zoom In");
		
		if fade_out_player != null :
			fade_out_player.play_tween_name("Reset");
		
		if fade_in_player != null:
			fade_in_player.play_tween_name("Fade In");
			await fade_in_player.tween_ended;
	else:
		AudioManager.play_sfx("battle_out")
		
		if fade_out_player != null :
			fade_out_player.play_tween_name("Fade Out");
			await fade_out_player.tween_ended;
			
			if fade_in_player != null :
				fade_in_player.play_tween_name("Reset");
	
	EventManager.battle_fade_completed.emit(fade_in);


func _on_destroy():
	if EventManager != null:
		EventManager.battle_fade_start.disconnect(_fade_action);
