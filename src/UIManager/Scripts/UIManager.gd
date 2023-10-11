extends Node

var active_menus: Array[MenuPanel];


func open_menu(menu : MenuPanel):
	var index = active_menus.find(menu);
	
	# Check if menu is already active
	if index > -1:
		active_menus.remove_at(index);
		
	# Add the menu to the list, giving it priority
	active_menus.push_back(menu);
	menu.initial_selection.grab_focus();


func close_menu(menu : MenuPanel):
	var index = active_menus.find(menu);
	
	# Remove menu if it is in the list
	if index > -1:
		active_menus.remove_at(index);
