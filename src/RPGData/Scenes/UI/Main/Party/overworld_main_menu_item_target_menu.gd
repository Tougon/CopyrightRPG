extends MenuPanel

@export var preview_image : TextureRect;
var _current_item : Item;
var _result : ItemResult;

var _current_index : int = -1;
var _awaiting_input : bool = false;


func _ready():
	super._ready();
	
	EventManager.on_inventory_item_selected.connect(_on_item_selected);
	
	for i in all_selections.size():
		(all_selections[i] as Button).focus_entered.connect(_on_player_selected.bind(i))
		(all_selections[i] as Button).pressed.connect(_on_player_pressed.bind(i))


func _on_item_selected(item : Item):
	_current_item = item;


func _can_use_item(id : int) -> bool:
	var can_use_item = false;
	
	if _current_item is ConsumableItem :
		can_use_item = (_current_item as ConsumableItem).check_can_use_item_overworld(id);
		
	return can_use_item;


func _on_player_selected(id : int):
	var entity_data = DataManager.party_data[id];
	var entity_id = entity_data.id;
	var entity = DataManager.entity_database.get_entity(entity_id);
	 
	preview_image.texture = ResourceLoader.load(entity.entity_sprites[3], "Texture2D") as Texture2D;
	
	if _current_index != id :
		preview_image.get_node("TweenPlayerUI").play_tween_name("Zap");
	_current_index = id;
	
	_result = ItemResult.new();
	
	var item_id = DataManager.item_database.get_id(_current_item);
	
	if _current_item is ConsumableItem :
		for effect in _current_item.on_use:
			effect.execute_overworld(id, _current_item, true, _result);
	
	var hp = entity.get_hp(entity_data.level);
	var mp = entity.get_mp(entity_data.level);
	
	var current_weapon = DataManager.item_database.get_item(entity_data.weapon_id);
	var current_armor = DataManager.item_database.get_item(entity_data.armor_id);
	var current_accessory = DataManager.item_database.get_item(entity_data.accessory_id);
	var all_equipment = [current_weapon, current_armor, current_accessory];
	
	for e in all_equipment:
		if e != null:
			hp += (e as EquipmentItem).hp_mod;
			mp += (e as EquipmentItem).mp_mod;
	
	$"../Visuals/Player Info/Bars/HP".visible = _result.show_hp;
	$"../Visuals/Player Info/Bars/HP".set_values_immediate(entity_data.hp_value, 0, hp)
	$"../Visuals/Player Info/Bars/HP".set_underlay_value(_result.hp_mod as float);
	
	$"../Visuals/Player Info/Bars/MP".visible = _result.show_mp;
	$"../Visuals/Player Info/Bars/MP".set_values_immediate(entity_data.mp_value, 0, mp)
	$"../Visuals/Player Info/Bars/MP".set_underlay_value(_result.mp_mod as float);


func _on_player_pressed(id : int):
	var item_used = false;
	var item_id = -1;
	
	var current_selection = UIManager.current_selection;
	UIManager.suspend_selection(true);
	
	if !_can_use_item(id) :
		$"../Visuals/Player Info/Description".text = tr("T_ITEM_DESCRIPTION_NO_EFFECT");
	
	else :
		item_used = true;
		var hp_delta = DataManager.party_data[id].hp_value;
		var mp_delta = DataManager.party_data[id].mp_value;
		
		item_id = DataManager.item_database.get_id(_current_item);
		
		if _current_item is ConsumableItem :
			for effect in _current_item.on_use:
				effect.execute_overworld(id, _current_item);
			DataManager.change_item_amount(item_id, -1);
		
		# Play animation(s)
		$"../Visuals/Player Info/Description".text = "";
		
		if _result.show_hp : 
			$"../Visuals/Player Info/Bars/HP".set_value(_result.hp_mod);
		if _result.show_mp :
			$"../Visuals/Player Info/Bars/MP".set_value(_result.mp_mod);
		
		hp_delta -= DataManager.party_data[id].hp_value;
		mp_delta -= DataManager.party_data[id].mp_value;
		
		await get_tree().create_timer(0.5).timeout;
		
		# Display restore message
		if _result.show_hp && _result.show_mp : 
			$"../Visuals/Player Info/Description".text = tr("T_ITEM_DESCRIPTION_HP_MP_RESTORE").format({hp = str(abs(hp_delta)), mp = str(abs(mp_delta))});
		if _result.show_hp : 
			$"../Visuals/Player Info/Description".text = tr("T_ITEM_DESCRIPTION_HP_RESTORE").format({hp = str(abs(hp_delta))});
		if _result.show_mp : 
			$"../Visuals/Player Info/Description".text = tr("T_ITEM_DESCRIPTION_MP_RESTORE").format({mp = str(abs(mp_delta))});
	
	_awaiting_input = true;
	while _awaiting_input :
		await get_tree().process_frame;
	
	UIManager.suspend_selection(false);
	current_selection.grab_focus();
	$"../Visuals/Player Info/Description".text = tr("T_ITEM_DESCRIPTION_USE_ITEM");
	
	# Should never be less than 0 but y'know~
	if item_used && DataManager.get_item_amount(item_id) <= 0:
		UIManager.close_menu_name("overworld_menu_main_item_target");
		UIManager.close_menu_name("overworld_menu_main_item_use");


func on_menu_active():
	super.on_menu_active();
	$"../Item Use Panel".visible = false;
	$"../Visuals/Player Info".visible = true;
	$"../Visuals/Player Info/Description".text = tr("T_ITEM_DESCRIPTION_USE_ITEM");
	
	var new_selection : Control;
	
	for i in all_selections.size():
		if i >= DataManager.party_data.size() || !DataManager.party_data[i].unlocked :
			all_selections[i].disabled = true;
			all_selections[i].visible = false;
		else:
			var can_use_item = false;
			
			if _current_item is ConsumableItem :
				can_use_item = (_current_item as ConsumableItem).check_can_use_item_overworld(i);
			
			#all_selections[i].disabled = !can_use_item;
			all_selections[i].visible = true;
			all_selections[i].text = tr(DataManager.entity_database.get_entity(DataManager.party_data[i].id).name_key);
			if new_selection == null : new_selection = all_selections[i]
	
	initial_selection = new_selection;


func on_menu_inactive():
	$"../Item Use Panel".visible = true;
	$"../Visuals/Player Info".visible = false;
	EventManager.refresh_current_inventory_item.emit();
	super.on_menu_inactive();


func _unhandled_input(event):
	if !_awaiting_input : return;
	
	if (event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_cancel")):
		accept_event();
		_awaiting_input = false;

func _exit_tree() :
	if EventManager != null : 
		EventManager.on_inventory_item_selected.disconnect(_on_item_selected);
