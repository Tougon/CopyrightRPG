extends MenuPanel
class_name OverworldSubmenu;

@export var root_menu : MenuPanel;
var last_selection : Control;


func on_menu_cancel():
	if !UIManager.is_closing_all :
		UIManager.close_all_menus();


func on_ui_trigger_l():
	root_menu.previous_tab();


func on_ui_trigger_r():
	root_menu.next_tab();


func set_active(state : bool):
	if !state : cache_menu_state();
	else : AudioManager.play_sfx("main_menu_tab_change");
	super.set_active(state);


func set_focus(state : bool):
	super.set_focus(state);


func on_focus():
	super.on_focus();
	if last_selection != null :
		initial_selection = last_selection;


func cache_menu_state():
	var selection = get_viewport().gui_get_focus_owner();
	
	if selection != null:
		last_selection = selection;
