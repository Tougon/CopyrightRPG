extends MenuPanel

@export var menu_panel : DynamicMenuPanel;


func _ready():
	super._ready();
	
	# Inventory listeners
	menu_panel.on_item_selected.connect(_on_item_selected);


func _on_item_selected(data):
	var item = DataManager.item_database.get_item(data);
	
	# Show/hide buttons depending on what the item's type is
	# TODOGAME: Could see usable key items being a thing that needs addressing
	if item != null :
		# Show all options
		if item is ConsumableItem :
			initial_selection = all_selections[0];
			
			all_selections[0].visible = true;
			all_selections[1].visible = true;
			all_selections[2].visible = true;
			
			all_selections[0].focus_neighbor_top = all_selections[0].get_path();
			all_selections[0].focus_neighbor_bottom = all_selections[0].get_path();
			all_selections[0].focus_neighbor_left = all_selections[2].get_path();
			all_selections[0].focus_neighbor_right = all_selections[1].get_path();
			
			all_selections[1].focus_neighbor_top = all_selections[1].get_path();
			all_selections[1].focus_neighbor_bottom = all_selections[1].get_path();
			all_selections[1].focus_neighbor_left = all_selections[0].get_path();
			all_selections[1].focus_neighbor_right = all_selections[2].get_path();
			
			all_selections[2].focus_neighbor_top = all_selections[2].get_path();
			all_selections[2].focus_neighbor_bottom = all_selections[2].get_path();
			all_selections[2].focus_neighbor_left = all_selections[1].get_path();
			all_selections[2].focus_neighbor_right = all_selections[0].get_path();
		# Show Drop and Cancel
		elif item is MoveItem || item is EquipmentItem:
			initial_selection = all_selections[1];
			
			all_selections[0].visible = false;
			all_selections[1].visible = true;
			all_selections[2].visible = true;
			
			all_selections[1].focus_neighbor_top = all_selections[1].get_path();
			all_selections[1].focus_neighbor_bottom = all_selections[1].get_path();
			all_selections[1].focus_neighbor_left = all_selections[2].get_path();
			all_selections[1].focus_neighbor_right = all_selections[2].get_path();
			
			all_selections[2].focus_neighbor_top = all_selections[2].get_path();
			all_selections[2].focus_neighbor_bottom = all_selections[2].get_path();
			all_selections[2].focus_neighbor_left = all_selections[1].get_path();
			all_selections[2].focus_neighbor_right = all_selections[1].get_path();
		# Show only Cancel
		else :
			initial_selection = all_selections[2];
			
			all_selections[0].visible = false;
			all_selections[1].visible = false;
			all_selections[2].visible = true;
			
			all_selections[2].focus_neighbor_top = all_selections[2].get_path();
			all_selections[2].focus_neighbor_bottom = all_selections[2].get_path();
			all_selections[2].focus_neighbor_left = all_selections[2].get_path();
			all_selections[2].focus_neighbor_right = all_selections[2].get_path();
			pass;


func _on_cancel_pressed() -> void:
	set_active(false);
	AudioManager.play_sfx("main_menu_submenu_close");


func _on_button_focus_entered() -> void:
	AudioManager.play_sfx("main_menu_select");
