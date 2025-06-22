extends MenuPanel

@export var menu_panel : RadialCarousel;

var _current_equipment_type : EquipmentItem.EquipmentType;
var _current_player_data : PartyMemberData;
var _current_player_entity : Entity;
var _current_equipment_id : int;

func _ready() -> void:
	super._ready();
	
	EventManager.on_player_equipment_selected.connect(_on_player_equipment_selected);
	
	menu_panel.on_item_highlighted.connect(_on_item_selected);
	menu_panel.on_item_clicked.connect(_on_item_clicked);
	menu_panel.on_scroll.connect(_on_scroll);


func _on_player_equipment_selected(equipment_type : EquipmentItem.EquipmentType, player_data : PartyMemberData, entity : Entity):
	_current_equipment_type = equipment_type;
	_current_player_data = player_data;
	_current_player_entity = entity;
	
	match _current_equipment_type:
		EquipmentItem.EquipmentType.Weapon:
			_current_equipment_id = _current_player_data.weapon_id;
		
		EquipmentItem.EquipmentType.Armor:
			_current_equipment_id = _current_player_data.armor_id;
		
		EquipmentItem.EquipmentType.Accessory:
			_current_equipment_id = _current_player_data.accessory_id;
	
	_refresh_equipment_ui();


# UI Display Functions
func on_focus():
	super.on_focus();
	await get_tree().process_frame;
	
	if menu_panel.get_data_size() > 0 :
		menu_panel.set_index(0);
		$BG/RadialCarousel.grab_focus();
	else :
		$"BG/Item Visuals/Description".text = "";
		$BG/None.visible = true;
		$"BG/Item Visuals/Equipment/Static".visible = true;
		$"BG/Item Visuals/Close".visible = true;
		$"BG/Item Visuals/Close".grab_focus();


func _refresh_equipment_ui():
	# Determine a valid list of equipment
	var valid_items : Array[EquipmentItem];
	
	var inventory = DataManager.get_equipment_items(true, _current_equipment_type);
	
	# If the item is not currently selected, it is valid
	for item_id  in inventory.keys():
		var is_valid = true;
		
		match _current_equipment_type:
			EquipmentItem.EquipmentType.Weapon:
				if item_id == _current_player_data.weapon_id:
					is_valid = false;
			
			EquipmentItem.EquipmentType.Armor:
				if item_id == _current_player_data.armor_id:
					is_valid = false;
			
			EquipmentItem.EquipmentType.Accessory:
				if item_id == _current_player_data.accessory_id:
					is_valid = false;
		
		if is_valid :
			var item = inventory[item_id];
			valid_items.append(item);
	
	if inventory.size() == 0 && _current_equipment_id == -1:
		$"BG/Item Visuals/Description".text = "";
		$BG/None.visible = true;
		
		match _current_equipment_type:
			EquipmentItem.EquipmentType.Weapon:
				$BG/None.text = tr("T_MENU_COMMON_PARTY_NO_WEAPON");
			
			EquipmentItem.EquipmentType.Armor:
				$BG/None.text = tr("T_MENU_COMMON_PARTY_NO_ARMOR");
			
			EquipmentItem.EquipmentType.Accessory:
				$BG/None.text = tr("T_MENU_COMMON_PARTY_NO_ACCESSORIES");
		
		$"BG/Item Visuals/Equipment/Static".visible = true;
		$"BG/Item Visuals/Close".visible = true;
		$"BG/Item Visuals/Close".grab_focus();
	else :
		if _current_equipment_id != -1:
			valid_items.append(null);
		$BG/None.visible = false;
		$"BG/Item Visuals/Close".visible = false;
	
	menu_panel.set_data(valid_items);


func _on_scroll():
	$"BG/Item Visuals/Equipment/TweenPlayerUI".play_tween_name("Zap");


func _on_item_selected(data):
	if data != null  && data is EquipmentItem:
		$"BG/Item Visuals/Description".text = tr(data.item_description_key);
		$"BG/Item Visuals/Equipment".texture = load_image((data as EquipmentItem).item_icon_path);
		$"BG/Item Visuals/Equipment/Static".visible = false;
		EventManager.on_equipment_item_highlighted.emit(data as EquipmentItem, _current_equipment_type);
	
	else :
		$"BG/Item Visuals/Description".text = tr("T_ITEM_DESCRIPTION_NONE");
		$"BG/Item Visuals/Equipment/Static".visible = true;
		EventManager.on_equipment_item_highlighted.emit(null, _current_equipment_type);


func load_image(path : String) -> Texture2D:
	if ResourceLoader.exists(path, "Texture2D"):
		var texture = ResourceLoader.load(path, "Texture2D") as Texture2D;
		return texture;
	return null;


func _on_item_clicked(data):
	var result_id : int;
	
	if data == null : result_id = -1;
	else : 
		result_id = DataManager.item_database.get_id(data);
	
	# Add previous back to inventory and remove new selection
	match _current_equipment_type:
		EquipmentItem.EquipmentType.Weapon:
			if result_id != _current_player_data.weapon_id:
				DataManager.change_item_amount(_current_player_data.weapon_id, 1);
				DataManager.change_item_amount(result_id, -1);
		
		EquipmentItem.EquipmentType.Armor:
			if result_id != _current_player_data.armor_id:
				DataManager.change_item_amount(_current_player_data.armor_id, 1);
				DataManager.change_item_amount(result_id, -1);
		
		EquipmentItem.EquipmentType.Accessory:
			if result_id != _current_player_data.accessory_id:
				DataManager.change_item_amount(_current_player_data.accessory_id, 1);
				DataManager.change_item_amount(result_id, -1);
	
	# Invoke update for player equipment
	EventManager.refresh_player_equipment.emit(_current_equipment_type, result_id);
	
	set_active(false);


func _on_close_pressed() -> void:
	set_active(false);


func _exit_tree() :
	if EventManager != null :
		EventManager.on_player_equipment_selected.disconnect(_on_player_equipment_selected);
