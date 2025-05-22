extends CanvasLayer

@export var fade_sequence : TweenPlayer;

# TODO: This currently makes no distinction about the enemies
# We will eventually want different animations for bosses and the like
func _ready():
	EventManager.overworld_battle_fade_start.connect(_fade_action_battle);
	EventManager.overworld_cutscene_fade_start.connect(_fade_action_cutscene);
	EventManager.overworld_cutscene_fade_instant.connect(_fade_action_cutscene_instant);
	EventManager.overworld_transition_fade_start.connect(_fade_action_transition);
	visible = true;


func _fade_action_battle(fade_in : bool):
	var origin = OverworldManager.get_player_screen_position();
	print("Origin Point: " + str(origin))
	$Erode.material.set_shader_parameter("origin", origin);
	
	if fade_sequence != null:
		if fade_in:
			fade_sequence.play_tween_name("Battle Fade In");
		else:
			fade_sequence.play_tween_name("Battle Fade Out");
			
			# Audio
			EventManager.play_sfx.emit("no");
		await fade_sequence.tween_ended;
	
	EventManager.overworld_battle_fade_completed.emit(fade_in);
	
	if fade_sequence != null:
		fade_sequence.play_tween_name("Battle Fade Complete");


func _fade_action_cutscene(fade_in : bool):
	if fade_sequence != null:
		if fade_in:
			fade_sequence.play_tween_name("Cutscene Fade In");
		else:
			fade_sequence.play_tween_name("Cutscene Fade Out");
		await fade_sequence.tween_ended;
	
	EventManager.overworld_cutscene_fade_completed.emit(fade_in);


func _fade_action_cutscene_instant(fade_in : bool):
	if fade_sequence != null:
		if fade_in:
			fade_sequence.play_tween_name("Cutscene Fade In Instant");
		else:
			fade_sequence.play_tween_name("Cutscene Fade Out Instant");
		await fade_sequence.tween_ended;
	
	EventManager.overworld_cutscene_fade_completed.emit(fade_in);


func _fade_action_transition(fade_in : bool):
	# TODO: Use unique sequences instead of copying the cutscene fades
	if fade_sequence != null:
		if fade_in:
			fade_sequence.play_tween_name("Cutscene Fade In");
		else:
			fade_sequence.play_tween_name("Cutscene Fade Out");
		await fade_sequence.tween_ended;
	
	EventManager.overworld_transition_fade_completed.emit(fade_in);


func _on_destroy():
	if EventManager != null:
		EventManager.overworld_battle_fade_start.disconnect(_fade_action_battle);
		EventManager.overworld_cutscene_fade_start.disconnect(_fade_action_cutscene);
		EventManager.overworld_cutscene_fade_instant.disconnect(_fade_action_cutscene_instant);
		EventManager.overworld_transition_fade_start.disconnect(_fade_action_transition);
