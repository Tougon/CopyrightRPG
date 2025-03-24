extends MenuPanel

@export var menu_panel : DynamicMenuPanel;

var _target_index : int;
var _current_player_data : PartyMemberData;
var _current_player_entity : Entity;
var _spell_to_item_id : Dictionary;

# TODO: Move order customization
func _ready():
	super._ready();
	
	EventManager.on_player_move_selected.connect(_on_player_move_selected);
	
	menu_panel.on_item_selected.connect(_on_item_selected);
	menu_panel.on_item_clicked.connect(_on_item_clicked);


func _on_player_move_selected(move_index : int, player_data : PartyMemberData, entity : Entity):
	_target_index = move_index;
	_current_player_data = player_data;
	_current_player_entity = entity;
	
	_refresh_move_ui();


# UI Display Functions
func on_focus():
	super.on_focus();
	await get_tree().process_frame;
	
	if menu_panel.get_data_size() > 0 :
		menu_panel.set_selected_index(0);
	else :
		$"BG/Move Visuals/Close".grab_focus();


func _refresh_move_ui():
	# Determine a valid list of moves based on the rules:
	var valid_moves : Array[Spell];
	
	# 1. The current selection
	var id = _current_player_data.move_list[_target_index];
	var current_selection : Spell;
	
	if id is String :
		current_selection = _current_player_entity.move_list.list[int(id)].spell;
	elif id is int :
		if id != -1 :
			var item = DataManager.item_database.get_item(id) as MoveItem;
			current_selection = item.move;
	
	if current_selection != null :
		valid_moves.append(current_selection);
	
	# 2. All moves in the player's move list that aren't set
	for move in _current_player_entity.move_list.list:
		if !_is_move_set(move.spell):
			valid_moves.append(move.spell);
	
	# 3. All unique moves in the inventory that aren't set
	var inventory = DataManager.get_move_items();
	_spell_to_item_id.clear();
	
	for move_id in inventory.keys():
		var move = inventory[move_id];
		_spell_to_item_id[move.move] = move_id;
		
		if !_is_move_set(move.move):
			valid_moves.append(move.move);
	
	# 4. None (null) if the player has more than one move set
	if _get_num_moves_set() > 1 :
		valid_moves.append(null);
	
	menu_panel.set_data(valid_moves);
	
	if valid_moves.size() == 0:
		$"BG/Move Visuals/Vid/Name".text = tr("T_MENU_COMMON_PARTY_NO_MOVES_DESC");
		$"BG/Move Visuals/Description".text = "";
		$"BG/Move Visuals/Cost".text = "";
		$BG/Label.visible = true;
		$"BG/Move Visuals/Close".visible = true;
		$"BG/Move Visuals/Close".grab_focus();
	else :
		$BG/Label.visible = false;
		$"BG/Move Visuals/Close".visible = false;

func _get_num_moves_set() -> int:
	var result = 0;
	
	for move in _current_player_data.move_list:
		if int(move) != -1 :
			result += 1;
	
	return result;


func _get_local_move_id(move : Spell) -> int:
	for id in _current_player_entity.move_list.list.size():
		if _current_player_entity.move_list.list[id].spell == move: return id;
	
	return -1;


func _is_move_set(move : Spell) -> bool:
	var target : Spell;
	
	for id in _current_player_data.move_list :
		if id is String :
			target = _current_player_entity.move_list.list[int(id)].spell;
		elif id is int :
			if id != -1 :
				var item = DataManager.item_database.get_item(id) as MoveItem;
				target = item.move;
		
		if target != null && target == move : return true;
	
	return false;


func _on_item_selected(data):
	if data != null  && data is Spell:
		$"BG/Move Visuals/Vid/Name".text = tr(data.spell_name_key);
		$"BG/Move Visuals/Description".text = tr(data.spell_description_key);
		$"BG/Move Visuals/Cost".text = tr("T_MP_COST").format({cost = data.spell_cost});
	
	else :
		$"BG/Move Visuals/Vid/Name".text = tr("T_SPELL_STATUS_COMMON_NONE");
		$"BG/Move Visuals/Description".text = tr("T_DESCRIPTION_SPELL_STATUS_COMMON_NONE");
		$"BG/Move Visuals/Cost".text = "-";


func _on_item_clicked(data):
	var result_id : int;
	var is_item = _spell_to_item_id.has(data);
	
	if data == null : result_id = -1;
	elif is_item : 
		result_id = _spell_to_item_id[data];
		# Remove item from list
		DataManager.change_item_amount(result_id, -1);
	else : result_id = _get_local_move_id(data);
	
	var new_move_list : Array;
	
	for i in GameplayConstants.MAX_PLAYER_MOVE_LIST_SIZE:
		if i == _target_index :
			if result_id != -1:
				if is_item : new_move_list.append(result_id);
				else : new_move_list.append(str(result_id));
			
			if _current_player_data.move_list[i] is int && _current_player_data.move_list[i] != -1:
				DataManager.change_item_amount(_current_player_data.move_list[i], 1);
		else :
			if int(_current_player_data.move_list[i]) != -1 :
				new_move_list.append(_current_player_data.move_list[i]);
	
	var filled_entries = new_move_list.size();
	
	for i in range(filled_entries, GameplayConstants.MAX_PLAYER_MOVE_LIST_SIZE):
		new_move_list.append(-1);
	
	# Invoke update for player move list
	EventManager.refresh_player_move_list.emit(new_move_list);
	
	set_active(false);


func _on_close_pressed() -> void:
	set_active(false);


func _exit_tree() :
	if EventManager != null :
		EventManager.on_player_move_selected.disconnect(_on_player_move_selected);
