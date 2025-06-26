extends MenuPanel

var _current_item : Item;

func _ready():
	super._ready();
	
	EventManager.on_inventory_item_selected.connect(_on_item_selected);
	
	for i in all_selections.size():
		(all_selections[i] as Button).pressed.connect(_on_player_selected.bind(i))


func _on_item_selected(item : Item):
	_current_item = item;


func _on_player_selected(id : int):
	var item_id = DataManager.item_database.get_id(_current_item);
	print("USING ITEM:")
	if _current_item is ConsumableItem :
		for effect in _current_item.on_use:
			effect.execute_overworld(id, _current_item);
		DataManager.change_item_amount(item_id, -1);
	
	# TODO: Animation/SFX/Whatever
	
	# Should never be less than 0 but y'know~
	if DataManager.get_item_amount(item_id) <= 0:
		UIManager.close_menu_name("overworld_menu_main_item_target");
		UIManager.close_menu_name("overworld_menu_main_item_use");


func on_menu_active():
	super.on_menu_active();
	
	var new_selection : Control;
	
	for i in all_selections.size():
		if i >= DataManager.party_data.size() || !DataManager.party_data[i].unlocked :
			all_selections[i].disabled = true;
			all_selections[i].visible = false;
		else:
			var can_use_item = false;
			
			if _current_item is ConsumableItem :
				can_use_item = (_current_item as ConsumableItem).check_can_use_item_overworld(i);
			
			all_selections[i].disabled = !can_use_item;
			all_selections[i].visible = true;
			if new_selection == null : new_selection = all_selections[i]
	
	initial_selection = new_selection;


func _exit_tree() :
	if EventManager != null : 
		EventManager.on_inventory_item_selected.disconnect(_on_item_selected);
