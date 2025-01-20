extends MenuPanel
class_name OverworldSubmenu;

@export var root_menu : MenuPanel;
var last_selection : Control;


func on_menu_cancel():
	super.on_menu_cancel();
	root_menu.on_menu_cancel();


func on_ui_aux_1():
	root_menu.on_ui_aux_1();


func on_ui_aux_2():
	root_menu.on_ui_aux_2();


func set_active(state : bool):
	if !state : cache_menu_state();
	super.set_active(state);


func set_focus(state : bool):
	super.set_focus(state);


func on_focus():
	if last_selection != null :
		initial_selection = last_selection;


func cache_menu_state():
	var selection = get_viewport().gui_get_focus_owner();
	
	if selection != null:
		last_selection = selection;
