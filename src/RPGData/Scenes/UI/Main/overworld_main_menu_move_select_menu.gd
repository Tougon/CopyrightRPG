extends MenuPanel

@export var menu_panel : RadialCarousel;

var _target_index : int;
var _current_player_data : PartyMemberData;
var _current_player_entity : Entity;
var _current_player_material : Material;
var _spell_to_item_id : Dictionary;

var _materials : Array[Material];
var _videos : Array[VideoStream];
var _current_animation : AnimationSequenceObject;
var _current_frame : int = 1;

var _use_manual_time : bool = false;
var _manual_time : float = 0.0;

# TODO: Move order customization
func _ready():
	super._ready();
	
	EventManager.on_player_move_selected.connect(_on_player_move_selected);
	
	menu_panel.on_item_highlighted.connect(_on_item_selected);
	menu_panel.on_item_clicked.connect(_on_item_clicked);


func _on_player_move_selected(move_index : int, player_data : PartyMemberData, entity : Entity):
	_target_index = move_index;
	_current_player_data = player_data;
	_current_player_entity = entity;
	_current_player_material = load_material(_current_player_entity.entity_thought_pattern_material);
	
	_refresh_move_ui();


# UI Display Functions
func on_focus():
	super.on_focus();
	await get_tree().process_frame;
	
	if menu_panel.get_data_size() > 0 :
		menu_panel.set_index(0);
	else :
		$"BG/Move Visuals/Description".text = "";
		$"BG/Move Visuals/Cost".text = "";
		$BG/None.visible = true;
		$"BG/Move Visuals/Vid/Static".visible = true;
		$"BG/Move Visuals/Close".visible = true;
		$"BG/Move Visuals/Close".grab_focus();


func on_menu_inactive():
	super.on_menu_inactive();
	_current_animation = null;


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
	# Do not use this if the current slot has no move
	if _get_num_moves_set() > 1 && current_selection != null :
		valid_moves.append(null);
	
	menu_panel.set_data(valid_moves);
	
	if valid_moves.size() == 0:
		$"BG/Move Visuals/Description".text = "";
		$"BG/Move Visuals/Cost".text = "";
		$BG/None.visible = true;
		$"BG/Move Visuals/Vid/Static".visible = true;
		$"BG/Move Visuals/Close".visible = true;
		$"BG/Move Visuals/Close".grab_focus();
	else :
		$BG/None.visible = false;
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
		if data.spell_videos.size() > 0 :
			_load_spell_data(data as Spell)
		else :
			$"BG/Move Visuals/Vid/Static".visible = true;
	
	else :
		$"BG/Move Visuals/Vid/Name".text = tr("T_SPELL_STATUS_COMMON_NONE");
		$"BG/Move Visuals/Description".text = tr("T_DESCRIPTION_SPELL_STATUS_COMMON_NONE");
		$"BG/Move Visuals/Cost".text = "-";
		$"BG/Move Visuals/Vid/Static".visible = true;


func _load_spell_data(move : Spell):
	_current_frame = 1;
	_current_animation = null;
	await get_tree().process_frame;
	_current_animation = move.animation_sequence;
	
	$"BG/Move Visuals/Vid".material = _current_player_material;
	$"BG/Move Visuals/Vid/Static".visible = true;
	
	if move.spell_videos != null && move.spell_videos.size() > 0:
		_videos.clear();
		
		for i in move.spell_videos.size():
			_videos.append(load_video(move.spell_videos[i]));
		#print(_videos.size());
		
		# TODO: Delete
		var video = null;
		
		if video != null : 
			$"BG/Move Visuals/Vid".stream = video;
			$"BG/Move Visuals/Vid".play_video_at(0);
			$"BG/Move Visuals/Vid/Static".visible = false;
		else :
			$"BG/Move Visuals/Vid/Static".visible = true;
	
	if move.spell_video_materials != null && move.spell_video_materials.size() > 0:
		_materials.clear();
		
		for i in move.spell_video_materials.size():
			_materials.append(load_material(move.spell_video_materials[i]));
		#print(_materials.size());
	
	_animation_loop();


func _animation_loop():
	_use_manual_time = false;
	$"BG/Move Visuals/Vid/Static".visible = false;
	
	while _current_animation != null:
		for action in _current_animation.animation_sequence:
			if action.frame == _current_frame:
				if action.action is ASAChangeBackground:
					_process_bg_action(action.action);
				elif action.action is ASATerminateAnimation:
					_current_frame = 0;
		
		await get_tree().process_frame;
		
		_current_frame += 1;
		
		if _use_manual_time :
			var delta = get_process_delta_time();
			_manual_time += delta;
			$"BG/Move Visuals/Vid".material.set_shader_parameter("manual_time", _manual_time)


func _process_bg_action(action : ASAChangeBackground):
	if action == null : return;
	
	if !action.reset_bg : 
		match action.mode:
			ASAChangeBackground.BGChangeMode.BOTH :
				_change_video(action.index);
				_change_material(action.index, !action.use_palette, action.palette_fade_time);
			ASAChangeBackground.BGChangeMode.VIDEO_ONLY :
				_change_video(action.index);
			ASAChangeBackground.BGChangeMode.MATERIAL_ONLY :
				_change_material(action.index, !action.use_palette, action.palette_fade_time);


func _change_video(index : int):
	if index >= 0 && index < _videos.size():
		$"BG/Move Visuals/Vid".stream = _videos[index];
		$"BG/Move Visuals/Vid".play_video_at(0);


func _change_material(index : int, use_entity_palette : bool, palette_transition_duration : float):
	if index >= 0 && index < _materials.size():
		var vplayer = $"BG/Move Visuals/Vid";
		var previous = vplayer.material.get_shader_parameter("palette");
		vplayer.material = _materials[index];
		vplayer.material.set_shader_parameter("transition", 0.0);
		
		if use_entity_palette :
			vplayer.material.set_shader_parameter("transition_palette", previous);
			vplayer.material.set_shader_parameter("palette", _current_player_material.get_shader_parameter("palette"));
		else:
			vplayer.material.set_shader_parameter("transition_palette", previous);
		
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		var property = tween.tween_property(vplayer.material as ShaderMaterial, "shader_parameter/transition", 1.0, palette_transition_duration);
		
		if property != null : 
			property.set_trans(Tween.TRANS_QUART)
			property.set_ease(Tween.EASE_OUT)
			property.from(0.0);
		
		vplayer.material.set_shader_parameter("use_manual_time", true);
		_use_manual_time = true;
		_manual_time = 0.0;


func load_video(path : String) -> VideoStream:
	if ResourceLoader.exists(path, "VideoStream"):
		var video = ResourceLoader.load(path, "VideoStream") as VideoStream;
		return video;
	return null;


func load_material(path : String) -> Material:
	if ResourceLoader.exists(path, "Material"):
		var mat = ResourceLoader.load(path, "Material") as Material;
		return mat;
	return null;


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
