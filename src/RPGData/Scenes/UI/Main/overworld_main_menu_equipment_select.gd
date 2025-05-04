extends MenuPanel

@export var menu_panel : DynamicMenuPanel;

var _current_equipment_type : EquipmentItem.EquipmentType;
var _current_player_data : PartyMemberData;
var _current_player_entity : Entity;

func _ready() -> void:
	super._ready();
	
	EventManager.on_player_equipment_selected.connect(_on_player_equipment_selected);
	
	menu_panel.on_item_selected.connect(_on_item_selected);
	#menu_panel.on_item_clicked.connect(_on_item_clicked);


func _on_player_equipment_selected(equipment_type : EquipmentItem.EquipmentType, player_data : PartyMemberData, entity : Entity):
	_current_equipment_type = equipment_type;
	_current_player_data = player_data;
	_current_player_entity = entity;
	
	_refresh_equipment_ui();


# UI Display Functions
func on_focus():
	super.on_focus();
	await get_tree().process_frame;
	
	if menu_panel.get_data_size() > 0 :
		menu_panel.set_selected_index(0);
	else :
		$"BG/Item Visuals/Equipment/Name".text = tr("T_MENU_COMMON_PARTY_NO_EQUIPMENT_DESC");
		$"BG/Item Visuals/Description".text = "";
		$BG/Label.visible = true;
		$"BG/Item Visuals/Equipment/Static".visible = true;
		$"BG/Item Visuals/Close".visible = true;
		$"BG/Item Visuals/Close".grab_focus();


func _refresh_equipment_ui():
	# Determine a valid list of moves based on the rules:
	var valid_items : Array[EquipmentItem];
	
	# 1. All moves in the inventory that are of the current type
	var inventory = DataManager.get_equipment_items(true, _current_equipment_type);
	
	for item_id  in inventory.keys():
		var item = inventory[item_id];
		valid_items.append(item);
	
	# Do we need this? Like current behavior has no weapon but...
	# 2. None (null) if the player has more than one move set
	#if _get_num_moves_set() > 1 :
	#	valid_moves.append(null);
	
	menu_panel.set_data(valid_items);
	
	if valid_items.size() == 0:
		$"BG/Item Visuals/Equipment/Name".text = tr("T_ITEM_NAME_NONE");
		$"BG/Item Visuals/Description".text = "";
		$BG/Label.visible = true;
		$"BG/Item Visuals/Equipment/Static".visible = true;
		$"BG/Item Visuals/Close".visible = true;
		$"BG/Item Visuals/Close".grab_focus();
	else :
		$BG/Label.visible = false;
		$"BG/Item Visuals/Close".visible = false;



func _on_item_selected(data):
	if data != null  && data is EquipmentItem:
		$"BG/Item Visuals/Equipment/Name".text = tr("TODO Name");
		$"BG/Item Visuals/Description".text = tr("TODO Description");
		
		print("TODO: Load sprites")
	
	else :
		$"BG/Item Visuals/Equipment/Name".text = tr("T_ITEM_NAME_NONE");
		$"BG/Item Visuals/Description".text = tr("T_ITEM_DESCRIPTION_NONE");
		$"BG/Item Visuals/Equipment/Static".visible = true;


func _on_close_pressed() -> void:
	set_active(false);
