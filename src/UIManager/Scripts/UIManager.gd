extends Control

var active_menus: Array[MenuPanel];
var menus = {};
var current_hover : Control;

signal current_hover_changed(hover_item);
signal on_menu_opened(panel : MenuPanel);
signal on_menu_closed(panel : MenuPanel);
signal on_all_menus_closed();


func _unhandled_input(event):
	if active_menus.size() > 0 :
		var current = active_menus[active_menus.size()-1];
		
		if current.focused:
			if (event.is_action_pressed("ui_cancel")):
				current.on_menu_cancel();
				accept_event();
			
			if (event.is_action_pressed("ui_aux_1")):
				current.on_ui_aux_1();
				accept_event();
			
			if (event.is_action_pressed("ui_aux_2")):
				current.on_ui_aux_2();
				accept_event();


func add_menu(menu : MenuPanel):
	if !menus.has(menu.menu_name) || menus[menu.menu_name] == null:
		menus[menu.menu_name] = menu;


func remove_menu(menu : MenuPanel):
	var index = active_menus.find(menu);
	if index > -1:
		active_menus.remove_at(index);
	
	if menus.has(menu):
		menus.erase(menu)


func open_menu(menu : MenuPanel):
	var index = active_menus.find(menu);
	
	# Check if menu is already active
	if index > -1:
		active_menus.remove_at(index);
		
	# Add the menu to the list, giving it priority
	active_menus.push_back(menu);
	
	if menu.initial_selection != null:
		menu.initial_selection.grab_focus();
	else: 
		suspend_selection();
	
	on_menu_opened.emit(menu);


func close_all_menus():
	while active_menus.size() > 0:
		active_menus[active_menus.size() - 1].set_active(false);
	on_all_menus_closed.emit();


func close_menu(menu : MenuPanel):
	var index = active_menus.find(menu);
	
	if index > -1:
		active_menus.remove_at(index);
	else : return;
	
	on_menu_closed.emit(menu);
	
	if active_menus.size() > 0:
		active_menus[active_menus.size() - 1].initial_selection.grab_focus();
		active_menus[active_menus.size() - 1].set_focus(true);
	else:
		on_all_menus_closed.emit();


func open_menu_name(menu_name : String):
	if menus.has(menu_name) : 
		if active_menus.size() > 0:
			active_menus[active_menus.size() - 1].set_focus(false);
		menus[menu_name].set_active(true);


func close_menu_name(menu_name : String):
	if menus.has(menu_name) : 
		menus[menu_name].set_active(false);


func suspend_selection():
	var current_focus_control = get_viewport().gui_get_focus_owner();
	if current_focus_control:
		current_focus_control.release_focus()


func set_current_hover(hovered : Control):
	current_hover = hovered;
	current_hover_changed.emit(current_hover);
