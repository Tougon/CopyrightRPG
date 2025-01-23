extends OverworldSubmenu

@export var menu_panel : DynamicMenuPanel;
@export var no_items_display : Control;

var _last_selection_index : int = 0;
var _current_item : Item;

func _ready():
	super._ready();
	
	# Inventory listeners
	DataManager.on_inventory_changed.connect(_refresh_inventory_ui);
	
	menu_panel.on_item_selected.connect(_on_item_selected);
	menu_panel.on_item_clicked.connect(_on_item_clicked);
	
	_refresh_inventory_ui();


func set_active(state : bool):
	super.set_active(state);

# UI Display Functions
func _refresh_inventory_ui():
	var inventory = DataManager.get_inventory_as_array();
	
	menu_panel.set_data(inventory);
	no_items_display.visible = inventory.size() == 0


func _on_item_selected(data):
	# TODO: Preview images, etc
	pass;


func _on_item_clicked(data):
	_current_item = DataManager.item_database.get_item(data);
	EventManager.on_inventory_item_selected.emit(_current_item);
	
	# Do nothing if the item cannot be "used," it is a key item
	if !((_current_item is ConsumableItem) || (_current_item is EquipmentItem)):
		return;
	
	# TODO: Change text to "Equip" for equipment (if it's even done here)
	UIManager.open_menu_name("overworld_menu_main_item_use");


# Item usage functions
func _on_use_clicked() -> void:
	UIManager.open_menu_name("overworld_menu_main_item_target");


func _on_drop_clicked() :
	if _current_item == null : return;
	
	var item_id = DataManager.item_database.get_id(_current_item);
	DataManager.change_item_amount(item_id, -1);
	
	if DataManager.get_item_amount(item_id) <= 0:
		UIManager.close_menu_name("overworld_menu_main_item_use");


# UI utility functions
func on_focus():
	super.on_focus();
	await get_tree().process_frame;
	menu_panel.set_selected_index(_last_selection_index);


func cache_menu_state():
	_last_selection_index = menu_panel.get_selected_index();


func _exit_tree() :
	if DataManager != null :
		DataManager.on_inventory_changed.disconnect(_refresh_inventory_ui);
