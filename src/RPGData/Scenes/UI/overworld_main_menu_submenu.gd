extends MenuPanel

@export var root_menu : MenuPanel;


func on_menu_cancel():
	super.on_menu_cancel();
	root_menu.on_menu_cancel();


func on_ui_aux_1():
	root_menu.on_ui_aux_1();


func on_ui_aux_2():
	root_menu.on_ui_aux_2();


func set_focus(state : bool):
	super.set_focus(state);
	print("fuq: " + str(state))
