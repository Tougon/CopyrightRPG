extends OverworldSubmenu

@export_group("Navigation")
@export var next_player_node : Control;
@export var prev_player_node : Control;
@export var moveset_grid : Control;

var _current_player_index = 0;
var _current_player_data : PartyMemberData;
var _current_player_entity : Entity;

func _ready():
	super._ready();
	
	EventManager.refresh_player_move_list.connect(_on_refresh_player_move_list);
	EventManager.refresh_player_equipment.connect(_on_refresh_player_equipment);
	_set_entity_info(0);


# Party menu functions
func _set_entity_info(index : int):
	if index < 0 : index = DataManager.party_data.size() - 1;
	elif index >= DataManager.party_data.size() : index = 0;
	_current_player_index = index;
	
	# Get and calculate entity data
	_current_player_data = DataManager.party_data[index];
	_current_player_entity = DataManager.entity_database.get_entity(_current_player_data.id, true);
	
	var hp = _current_player_entity.get_hp(_current_player_data.level);
	var mp = _current_player_entity.get_mp(_current_player_data.level);
	var atk = _current_player_entity.get_atk(_current_player_data.level);
	var def = _current_player_entity.get_def(_current_player_data.level);
	var mag = _current_player_entity.get_sp_atk(_current_player_data.level);
	var res = _current_player_entity.get_sp_def(_current_player_data.level);
	var spd = _current_player_entity.get_spd(_current_player_data.level);
	var lck = _current_player_entity.get_lck(_current_player_data.level);
	
	# TODO: Animate portrait and name
	$"Entity Stats Area/Entity Portrait Group/Portrait/TweenPlayerUI".play_tween_name("Portrait Zap");
	
	if _current_player_entity.entity_sprites.size() > 3:
		$"Entity Stats Area/Entity Portrait Group/Portrait".texture = ResourceLoader.load(_current_player_entity.entity_sprites[3], "Texture2D") as Texture2D;
	$"Entity Stats Area/Entity Portrait Group/Name/Label".text = tr(_current_player_entity.name_key);
	$"Entity Stats Area/Entity Stats Group/Level/HBoxContainer/Value".text = str(_current_player_data.level);
	
	$"Entity Stats Area/Entity Stats Group/HP/Label".text = tr("T_HP") + ": " + str(hp - _current_player_data.hp_dmg) + "/" + str(hp);
	$"Entity Stats Area/Entity Stats Group/HP".value = ((hp as float) - (_current_player_data.hp_dmg as float)) / (hp as float)
	$"Entity Stats Area/Entity Stats Group/MP/Label".text = tr("T_MP") + ": " + str(mp - _current_player_data.mp_dmg) + "/" + str(mp);
	$"Entity Stats Area/Entity Stats Group/MP".value = ((mp as float) - (_current_player_data.mp_dmg as float)) / (mp as float)
	
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/ATK".set_stat_value(atk);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/DEF".set_stat_value(def);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/MAG".set_stat_value(mag);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/RES".set_stat_value(res);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/SPD".set_stat_value(spd);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/LCK".set_stat_value((lck * GameplayConstants.LUCK_SCALE));
	
	_refresh_move_list();


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
			
			if move != null:
				button.disabled = false;
				button.focus_mode = Control.FOCUS_ALL;
				button.text = tr(move.spell_name_key);
			else : 
				button.disabled = i > last_valid_index + 1;
				button.text = "+";
			
			if button.disabled : button.focus_mode = Control.FOCUS_NONE;
			
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


func _on_refresh_player_move_list(move_list : Array):
	_current_player_data.move_list = move_list;
	DataManager.party_data[_current_player_index].move_list = move_list;
	_refresh_move_list();


func _on_refresh_player_equipment(equipment_type : EquipmentItem.EquipmentType, item_id : int):
	match equipment_type:
		EquipmentItem.EquipmentType.Weapon:
			DataManager.party_data[_current_player_index].weapon_id = item_id;
	
	# TODO: Refresh visuals


# UI utility functions
func set_active(state : bool):
	if !state : cache_menu_state();
	super.set_active(state);


func on_focus():
	super.on_focus();
	if last_selection != null :
		initial_selection = last_selection;
		initial_selection.grab_focus();


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
		EventManager.refresh_player_move_list.disconnect(_on_refresh_player_move_list);
		EventManager.refresh_player_equipment.disconnect(_on_refresh_player_equipment);
