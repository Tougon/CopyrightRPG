extends MenuPanel

@export var header_icons : Array[TweenPlayer];
@export var submenus : Array[MenuPanel];

var _current_tab_index : int = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready();
	$"Header/Options Headers/GridContainer".modulate = Color.TRANSPARENT;


func _on_save_pressed():
	DataManager.save_data();
	AudioManager.play_sfx("main_menu_confirm")


func _on_load_pressed():
	DataManager.load_data();


func _on_delete_pressed():
	DataManager.delete_data();


func set_active(state : bool):
	if !state :
		submenus[_current_tab_index].set_active(false);
		for index in header_icons.size():
			header_icons[index].play_tween_name("Focus Exited");
		
		AudioManager.play_sfx("main_menu_close")
		EventManager.fade_bgm.emit(1, 0.5, false);
		
		super.set_active(state);
	else :
		super.set_active(state);
		
		AudioManager.play_sfx("main_menu_open")
		EventManager.fade_bgm.emit(0.45, 0.5, false);
		await get_tree().create_timer(0.25).timeout;
		_play_header_tweens();
		await get_tree().create_timer(0.15).timeout;
		submenus[_current_tab_index].set_active(true);


func set_active_forced(state : bool):
	super.set_active_forced(state);


# Removed to prevent obnoxious UI bugs.
#func on_menu_active():
	# Do not focus this menu
#	ui_manager.open_menu(self);
	#ui_manager.open_menu(submenus[_current_tab_index]);


func on_menu_inactive():
	super.on_menu_inactive();


func _play_header_tweens():
	for index in header_icons.size():
		if _current_tab_index == index :
			header_icons[index].play_tween_name("Focus Entered");
		else :
			header_icons[index].play_tween_name("Focus Exited");


func previous_tab():
	submenus[_current_tab_index].set_active(false);
	
	_current_tab_index -= 1;
	if _current_tab_index < 0 : _current_tab_index = header_icons.size() - 1;
	
	submenus[_current_tab_index].set_active(true);
	_play_header_tweens();


func next_tab():
	submenus[_current_tab_index].set_active(false);
	
	_current_tab_index += 1;
	if _current_tab_index >= header_icons.size() : _current_tab_index = 0;
	
	submenus[_current_tab_index].set_active(true);
	_play_header_tweens();


func on_menu_cancel():
	pass;
