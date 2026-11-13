extends MenuPanel

@export var player_boxes : Array[SkitPlayerBox];

var _current_skit : String;
var _box_map : Dictionary;
var _portrait_map : Dictionary;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	
	$Label.visible = false;
	$"Portrait Area".visible = false;
	$"Text Area".visible = false;
	
	EventManager.on_skit_play.connect(_on_skit_play);
	EventManager.on_skit_end.connect(_on_skit_end);
	
	Dialogic.speaker_changed.connect(_on_speaker_change);
	Dialogic.Portraits.character_joined.connect(_on_character_joined);
	
	for box in player_boxes :
		_box_map[box.speaker_name] = box;


func _on_skit_play(skit_name : String, skit_dialogue : String):
	_current_skit = skit_dialogue;
	$Label.text = skit_name;
	
	_portrait_map.clear();
	
	UIManager.open_menu_name(menu_name);


func _on_speaker_change(speaker : DialogicCharacter):
	if _current_skit.is_empty() : return;
	
	if speaker != null :
		print("SPEAKING: " + speaker.display_name);
		
		var speakers = speaker.display_name.split(",");
		var formatted_speakers : Array[String];
		
		for name in speakers :
			formatted_speakers.append(name.replace(" ", ""));
		
		for box in player_boxes :
			box.set_speaking(formatted_speakers.has(box.speaker_name));
			
			if _portrait_map.has(box.speaker_name) :
				var portrait = _portrait_map[box.speaker_name];
				
				box.tween_portrait(portrait, formatted_speakers.has(box.speaker_name));


func _on_character_joined(character_info : Dictionary):
	if _current_skit.is_empty() : return;
	
	if character_info != null :
		var character = character_info["character"]
		var node = character_info["node"];
		
		if !_portrait_map.has(character.display_name) :
			_portrait_map[character.display_name] = node.get_child(0);
			_box_map[character.display_name].initialize_portrait(node.get_child(0));


func _on_skit_end():
	set_active(false);
	_current_skit = "";


func on_focus():
	# Play the dialogue sequence
	Dialogic.Styles.change_style("skit_style", true);
	Dialogic.start(_current_skit);
	
	$Label.visible = true;
	$"Portrait Area".visible = true;
	$"Text Area".visible = true;


func on_unfocus():
	$Label.visible = false;
	$"Portrait Area".visible = false;
	$"Text Area".visible = false;


# Needs to be overwritten otherwise you can manually close this
func on_menu_cancel():
	pass;


func _exit_tree():
	if EventManager != null :
		EventManager.on_skit_play.disconnect(_on_skit_play);
		EventManager.on_skit_end.disconnect(_on_skit_end);
	
	if Dialogic != null :
		Dialogic.speaker_changed.disconnect(_on_speaker_change);
		Dialogic.Portraits.character_joined.disconnect(_on_character_joined);
