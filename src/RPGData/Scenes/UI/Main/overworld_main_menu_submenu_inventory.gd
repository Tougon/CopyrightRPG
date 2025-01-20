extends OverworldSubmenu

@export var menu_panel : DynamicMenuPanel;
@export var no_items_display : Control;

var _last_selection_index : int = 0;

func _ready():
	super._ready();
	
	# Inventory listeners
	DataManager.on_inventory_changed.connect(_refresh_inventory_ui);
	_refresh_inventory_ui();


func set_active(state : bool):
	print("Init");
	# Initialize menu
	# Evan: Are you insane? Don't initialize here!
	super.set_active(state);


func _refresh_inventory_ui():
	var inventory = DataManager.get_inventory_as_array();
	menu_panel.set_data(inventory);


func _on_item_selected():
	# Pass data in
	print("Selected")


func on_focus():
	await get_tree().process_frame;
	menu_panel.set_selected_index(_last_selection_index);


func cache_menu_state():
	_last_selection_index = menu_panel.get_selected_index();
