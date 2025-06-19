extends OverworldSubmenu

@export_group("Navigation")
@export var next_player_node : Control;
@export var prev_player_node : Control;
@export var moveset_grid : Control;

@export_group("Aesthetics")
@export var cursor : Control;
@export var equipment_empty_sprite : Texture;

var _current_player_index = 0;
var _current_player_data : PartyMemberData;
var _current_player_entity : Entity;

func _ready():
	super._ready();
	
	EventManager.refresh_player_info.connect(_on_refresh_entity_info);
	EventManager.refresh_player_move_list.connect(_on_refresh_player_move_list);
	EventManager.refresh_player_equipment.connect(_on_refresh_player_equipment);
	EventManager.on_equipment_item_highlighted.connect(_on_equipment_item_highlighted);
	_set_entity_info(0);
	
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed);


func _on_gui_focus_changed(node: Node):
	if focused && all_selections.has(node):
		cursor.global_position = node.global_position;


# Party menu functions
func _set_entity_info(index : int):
	if index < 0 : index = DataManager.party_data.size() - 1;
	elif index >= DataManager.party_data.size() : index = 0;
	_current_player_index = index;
	
	# Get and calculate entity data
	_current_player_data = DataManager.party_data[index];
	_current_player_entity = DataManager.entity_database.get_entity(_current_player_data.id, true);
	
	# TODO: Animate name?
	$"Entity Stats Area/Entity Portrait Group/Portrait/TweenPlayerUI".play_tween_name("Portrait Zap");
	
	if _current_player_entity.entity_sprites.size() > 3:
		$"Entity Stats Area/Entity Portrait Group/Portrait".texture = ResourceLoader.load(_current_player_entity.entity_sprites[3], "Texture2D") as Texture2D;
	$"Entity Stats Area/Entity Portrait Group/Name/Label".text = tr(_current_player_entity.name_key);
	$"Entity Stats Area/Entity Stats Group/Level/HBoxContainer/Value".text = str(_current_player_data.level);
	
	_display_entity_stats();
	_refresh_move_list();


func _display_entity_stats(compare : bool = false, equipment : EquipmentItem = null, equipment_type : EquipmentItem.EquipmentType = EquipmentItem.EquipmentType.Weapon):
	# Get current raw stat values
	var hp = _current_player_entity.get_hp(_current_player_data.level);
	var mp = _current_player_entity.get_mp(_current_player_data.level);
	var atk = _current_player_entity.get_atk(_current_player_data.level);
	var def = _current_player_entity.get_def(_current_player_data.level);
	var mag = _current_player_entity.get_sp_atk(_current_player_data.level);
	var res = _current_player_entity.get_sp_def(_current_player_data.level);
	var spd = _current_player_entity.get_spd(_current_player_data.level);
	var lck = _current_player_entity.get_lck(_current_player_data.level);
	
	# Get current equipment
	var comp_equipment : EquipmentItem;
	var current_weapon = DataManager.item_database.get_item(_current_player_data.weapon_id);
	var current_armor = DataManager.item_database.get_item(_current_player_data.armor_id);
	var current_accessory = DataManager.item_database.get_item(_current_player_data.accessory_id);
	var all_equipment = [current_weapon, current_armor, current_accessory];
	
	# Modify stats by weapon modifiers
	for e in all_equipment:
		if e != null:
			hp += (e as EquipmentItem).hp_mod;
			mp += (e as EquipmentItem).mp_mod;
			atk += (e as EquipmentItem).atk_mod;
			def += (e as EquipmentItem).def_mod;
			mag += (e as EquipmentItem).mag_mod;
			res += (e as EquipmentItem).res_mod;
			spd += (e as EquipmentItem).spd_mod;
			lck += (e as EquipmentItem).lck_mod;
			
			if (e as EquipmentItem).equipment_type == equipment_type:
				comp_equipment = e;
	
	# Get comparison stats if applicable
	var comp_hp = 0;
	var comp_mp = 0;
	var comp_atk = 0;
	var comp_def = 0;
	var comp_mag = 0;
	var comp_res = 0;
	var comp_spd = 0;
	var comp_lck = 0.0;
	
	if compare : 
		if equipment != null :
			comp_hp = equipment.hp_mod;
			comp_mp = equipment.mp_mod;
			comp_atk = equipment.atk_mod;
			comp_def = equipment.def_mod;
			comp_mag = equipment.mag_mod;
			comp_res = equipment.res_mod;
			comp_spd = equipment.spd_mod;
			comp_lck = (equipment.lck_mod * GameplayConstants.LUCK_SCALE);
		else :
			if comp_equipment != null : 
				comp_hp = -comp_equipment.hp_mod;
				comp_mp = -comp_equipment.mp_mod;
				comp_atk = -comp_equipment.atk_mod;
				comp_def = -comp_equipment.def_mod;
				comp_mag = -comp_equipment.mag_mod;
				comp_res = -comp_equipment.res_mod;
				comp_spd = -comp_equipment.spd_mod;
				comp_lck = -(comp_equipment.lck_mod * GameplayConstants.LUCK_SCALE);
	
	if comp_hp != 0 :
		if comp_hp > 0:
			$"Entity Stats Area/Entity Stats Group/HP/Label".text = tr("T_HP") + ": " + str(_current_player_data.hp_value) + "/" + str(hp) + " [color=#3ce864]+ " + str(comp_hp);
		else :
			$"Entity Stats Area/Entity Stats Group/HP/Label".text = tr("T_HP") + ": " + str(_current_player_data.hp_value) + "/" + str(hp) + " [color=#ed3b3e]- " + str(abs(comp_hp));
	else:
		$"Entity Stats Area/Entity Stats Group/HP/Label".text = tr("T_HP") + ": " + str(_current_player_data.hp_value) + "/" + str(hp);
	$"Entity Stats Area/Entity Stats Group/HP".value = ((_current_player_data.hp_value as float)) / (hp as float)
	
	if comp_mp != 0 :
		if comp_mp > 0:
			$"Entity Stats Area/Entity Stats Group/MP/Label".text = tr("T_MP") + ": " + str(_current_player_data.mp_value) + "/" + str(mp) + " [color=#3ce864]+ " + str(comp_mp);
		else :
			$"Entity Stats Area/Entity Stats Group/MP/Label".text = tr("T_MP") + ": " + str(_current_player_data.mp_value) + "/" + str(mp) + " [color=#ed3b3e]- " + str(abs(comp_mp));
	else :
		$"Entity Stats Area/Entity Stats Group/MP/Label".text = tr("T_MP") + ": " + str(_current_player_data.mp_value) + "/" + str(mp);
	$"Entity Stats Area/Entity Stats Group/MP".value = ((_current_player_data.mp_value as float)) / (mp as float)
	
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/ATK".set_stat_value(atk, comp_atk);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/DEF".set_stat_value(def, comp_def);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/MAG".set_stat_value(mag, comp_mag);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/RES".set_stat_value(res, comp_res);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/SPD".set_stat_value(spd, comp_spd);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/LCK".set_stat_value((lck * GameplayConstants.LUCK_SCALE), comp_lck);


func _refresh_move_list():
	var last_valid_index = 0;
	
	for i in moveset_grid.get_child_count():
		var move : Spell;
		var button = moveset_grid.get_child(i) as Button;
		
		if i < _current_player_data.move_list.size():
			var move_id = _current_player_data.move_list[i];
			
			# Check if the move is part of the player's base moveset
			if move_id is String:
				var as_int = int(move_id);
				move = _current_player_entity.move_list.list[as_int].spell;
				last_valid_index = i;
			
			elif move_id is int : 
				if move_id != -1:
					var item = DataManager.item_database.get_item(move_id);
					
					if item != null && item is MoveItem:
						move = (item as MoveItem).move;
						last_valid_index = i;
		
		if button != null : 
			button.focus_neighbor_left = "";
			button.focus_neighbor_right = "";
			button.modulate = Color(1,1,1,1);
			
			if move != null:
				button.disabled = false;
				button.focus_mode = Control.FOCUS_ALL;
				button.get_node("Root/Label").text = tr(move.spell_name_key);
				button.get_node("Root/Image").texture = null;
			else : 
				button.disabled = i > last_valid_index + 1;
				button.get_node("Root/Label").text = "";
				button.get_node("Root/Image").texture = equipment_empty_sprite;
			
			if button.disabled : 
				button.focus_mode = Control.FOCUS_NONE;
				button.modulate = Color(1,1,1,0.25);
			
			else : 
				button.focus_mode = Control.FOCUS_ALL;
				if i % 3 == 0 : button.focus_neighbor_left = button.get_path_to(prev_player_node);
				if (i + 1) % 3 == 0 || i == last_valid_index + 1 : button.focus_neighbor_right = button.get_path_to(next_player_node);


# Equipment Selection
func _on_weapon_selected():
	cache_menu_state();
	
	EventManager.on_player_equipment_selected.emit(EquipmentItem.EquipmentType.Weapon, _current_player_data, _current_player_entity);
	UIManager.open_menu_name("overworld_menu_main_equipment_select");
	pass;


func _on_armor_selected():
	cache_menu_state();
	
	EventManager.on_player_equipment_selected.emit(EquipmentItem.EquipmentType.Armor, _current_player_data, _current_player_entity);
	UIManager.open_menu_name("overworld_menu_main_equipment_select");
	pass;


func _on_accessory_selected():
	cache_menu_state();
	
	EventManager.on_player_equipment_selected.emit(EquipmentItem.EquipmentType.Accessory, _current_player_data, _current_player_entity);
	UIManager.open_menu_name("overworld_menu_main_equipment_select");
	pass;


# Move Selection
func _on_move_selected():
	var move_index = UIManager.current_selection.get_index();
	cache_menu_state();
	
	EventManager.on_player_move_selected.emit(move_index, _current_player_data, _current_player_entity);
	UIManager.open_menu_name("overworld_menu_main_move_select");


func _on_refresh_entity_info():
	_set_entity_info(_current_player_index);


func _on_refresh_player_move_list(move_list : Array):
	_current_player_data.move_list = move_list;
	DataManager.party_data[_current_player_index].move_list = move_list;
	_refresh_move_list();


func _on_refresh_player_equipment(equipment_type : EquipmentItem.EquipmentType, item_id : int):
	match equipment_type:
		EquipmentItem.EquipmentType.Weapon:
			DataManager.party_data[_current_player_index].weapon_id = item_id;
		
		EquipmentItem.EquipmentType.Armor:
			DataManager.party_data[_current_player_index].armor_id = item_id;
		
		EquipmentItem.EquipmentType.Accessory:
			DataManager.party_data[_current_player_index].accessory_id = item_id;
	
	# TODO: Refresh visuals


func _on_equipment_item_highlighted(equipment : EquipmentItem, equipment_type : EquipmentItem.EquipmentType) :
	_display_entity_stats(true, equipment, equipment_type);


# UI utility functions
func set_active(state : bool):
	if !state : cache_menu_state();
	super.set_active(state);


func on_focus():
	super.on_focus();
	if last_selection != null :
		initial_selection = last_selection;
		initial_selection.grab_focus();
	
	_display_entity_stats();


func _on_focus_entered_next():
	_set_entity_info(_current_player_index + 1);
	
	if UIManager.previous_selection.get_parent() == moveset_grid : 
		var last_valid = _get_last_valid_moveset_button();
		var last_valid_index = last_valid.get_index();
		
		var prev_index = UIManager.previous_selection.get_index();
		
		if last_valid_index > 2 && prev_index == 2 :
			UIManager.previous_selection.grab_focus();
		else : 
			last_valid.grab_focus();
	else :
		UIManager.previous_selection.grab_focus();


func _on_focus_entered_previous():
	_set_entity_info(_current_player_index - 1);
	
	if UIManager.previous_selection.get_parent() == moveset_grid : 
		var last_valid = _get_last_valid_moveset_button();
		var last_valid_index = last_valid.get_index();
		
		var prev_index = UIManager.previous_selection.get_index();
		
		if last_valid_index < 3 && prev_index == 3 :
			moveset_grid.get_child(0).grab_focus();
		else : 
			UIManager.previous_selection.grab_focus();
	else :
		UIManager.previous_selection.grab_focus();


func _get_last_valid_moveset_button() -> Control:
	var last_valid : Control;
	
	for child in moveset_grid.get_children():
		if !child.disabled : last_valid = child;
	
	return last_valid;


func on_ui_trigger_l():
	_set_entity_info(_current_player_index - 1);
	
	if UIManager.current_selection.get_parent() == moveset_grid : 
		var last_valid = _get_last_valid_moveset_button();
		var last_valid_index = last_valid.get_index();
		
		if last_valid_index < UIManager.current_selection.get_index():
			last_valid.grab_focus();


func on_ui_trigger_r():
	_set_entity_info(_current_player_index + 1);
	
	if UIManager.current_selection.get_parent() == moveset_grid : 
		var last_valid = _get_last_valid_moveset_button();
		var last_valid_index = last_valid.get_index();
		
		if last_valid_index < UIManager.current_selection.get_index():
			last_valid.grab_focus();


func cache_menu_state():
	var selection = UIManager.current_selection;
	
	if selection != null:
		last_selection = selection;


func _exit_tree() :
	if EventManager != null:
		EventManager.refresh_player_info.disconnect(_on_refresh_entity_info);
		EventManager.refresh_player_move_list.disconnect(_on_refresh_player_move_list);
		EventManager.refresh_player_equipment.disconnect(_on_refresh_player_equipment);
		EventManager.on_equipment_item_highlighted.disconnect(_on_equipment_item_highlighted);
