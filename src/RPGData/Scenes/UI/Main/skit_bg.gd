extends MenuPanel

var _current_skit : String;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	
	$Label.visible = false;
	$"Portrait Area".visible = false;
	$"Text Area".visible = false;
	
	EventManager.on_skit_play.connect(_on_skit_play);
	EventManager.on_skit_end.connect(_on_skit_end);


func _on_skit_play(skit_name : String, skit_dialogue : String):
	_current_skit = skit_dialogue;
	$Label.text = skit_name;
	
	UIManager.open_menu_name(menu_name);


func _on_skit_end():
	set_active(false);


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
		EventManager.on_skit_end.connect(_on_skit_end);
