extends MenuPanel

@export var header_icons : Array[TweenPlayer];
var _current_tab_index : int = 4;

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready();
	$"Header/Options Headers/GridContainer".modulate = Color.TRANSPARENT;


func _on_save_pressed():
	DataManager.save_data();


func _on_load_pressed():
	DataManager.load_data();


func _on_delete_pressed():
	DataManager.delete_data();


func set_active(state : bool):
	super.set_active(state);
	
	if !state :
		for index in header_icons.size():
			header_icons[index].play_tween_name("Focus Exited");
	else :
		await get_tree().create_timer(0.25).timeout;
		_play_header_tweens();


func set_active_forced(state : bool):
	super.set_active_forced(state);


func on_menu_active():
	super.on_menu_active();
	
	_play_header_tweens();


func on_menu_inactive():
	super.on_menu_inactive();


func _play_header_tweens():
	for index in header_icons.size():
		if _current_tab_index == index :
			header_icons[index].play_tween_name("Focus Entered");
		else :
			header_icons[index].play_tween_name("Focus Exited");


func on_ui_aux_1():
	_current_tab_index -= 1;
	if _current_tab_index < 0 : _current_tab_index = header_icons.size() - 1;
	
	_play_header_tweens();


func on_ui_aux_2():
	_current_tab_index += 1;
	if _current_tab_index >= header_icons.size() : _current_tab_index = 0;
	
	_play_header_tweens();
