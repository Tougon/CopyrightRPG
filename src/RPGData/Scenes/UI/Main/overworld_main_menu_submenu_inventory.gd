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
	
	EventManager.refresh_current_inventory_item.connect(_refresh_current_item)
	
	_refresh_inventory_ui();


func set_active(state : bool):
	super.set_active(state);
	
	if state : _on_item_selected(-1);

# UI Display Functions
func _refresh_inventory_ui():
	var inventory = DataManager.get_inventory_as_array();
	
	menu_panel.set_data(inventory);
	no_items_display.visible = inventory.size() == 0;


func _on_item_selected(data):
	var item = DataManager.item_database.get_item(data);
	if item != null :
		$"Inventory Area/BG/Blocker/Display/Visuals/Description".text = tr(item.item_description_key);
		$"Inventory Area/BG/Blocker/Display/Visuals/Item Preview".texture = load_image(item.item_icon_path);
		$"Inventory Area/BG/Blocker/Display/Visuals/Item Preview/TweenPlayerUI".play_tween_name("Zap");
	else :
		$"Inventory Area/BG/Blocker/Display/Visuals/Description".text = "";
		$"Inventory Area/BG/Blocker/Display/Visuals/Item Preview".texture = null;


func _refresh_current_item():
	if _current_item == null : return;
	$"Inventory Area/BG/Blocker/Display/Visuals/Description".text = tr(_current_item.item_description_key);


func load_image(path : String) -> Texture2D:
	if ResourceLoader.exists(path, "Texture2D"):
		var texture = ResourceLoader.load(path, "Texture2D") as Texture2D;
		return texture;
	return null;


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
	$"Inventory Area/BG/Blocker/Display/Item Use Panel".visible = false;
	UIManager.open_menu_name("overworld_menu_main_item_drop");


func _on_drop_confirmed() :
	if _current_item == null : return;
	
	var item_id = DataManager.item_database.get_id(_current_item);
	DataManager.change_item_amount(item_id, -1);
	
	UIManager.close_menu_name("overworld_menu_main_item_drop");
	
	if DataManager.get_item_amount(item_id) <= 0:
		UIManager.close_menu_name("overworld_menu_main_item_use");


# UI utility functions
func on_focus():
	super.on_focus();
	await get_tree().process_frame;
	
	if _last_selection_index >= menu_panel.get_data_size():
		_last_selection_index = menu_panel.get_data_size() - 1;
	
	menu_panel.set_selected_index(_last_selection_index);


func on_unfocus():
	super.on_unfocus();
	cache_menu_state();

func cache_menu_state():
	_last_selection_index = menu_panel.get_selected_index();


func _exit_tree() :
	if DataManager != null :
		DataManager.on_inventory_changed.disconnect(_refresh_inventory_ui);
	
	if EventManager != null :
		EventManager.refresh_current_inventory_item.disconnect(_refresh_current_item)
