# Should this even inherit from menu panel? I don't think it should, personally
extends Panel
class_name DynamicMenuPanel

@export var container : ScrollContainer;
@export var menu_item: PackedScene
@export var item_size : Vector2 = Vector2(75.0, 75.0);
@export var item_spacing : Vector2 = Vector2(10.0, 10.0);
# Should export this later, too dangerous to use export now.
var horizontal : bool = false;

var _data : Array;

# Runtime variables for sizing and menu items
var _grid_size : Vector2i;
var _columns : int;
var _rows : int;
var _scroll_area : Control;
var _item_groups : Array[Array];
var _total_item_count : int;

# Runtime variables for selection and scrolling
var _last_pos : Vector2;
var _group_start_index : int;
var _current_selected_index : int = -1;
var _previous_selected_index : int = -1;
var _current_group_index : int = 0;
var _current_item_index : int = 0;
# Caching these but unclear if these will be used
var _last_group_index : int = 0;
var _last_item_index : int = 0;

signal on_item_selected(data);
signal on_item_clicked(data);


func _ready() -> void:
	if container != null:
		_scroll_area = container.get_child(0);
	
	if _scroll_area == null :
		print("ERROR: Invalid scroll area")
		return;
	
	_grid_size.x = _get_best_fit_amount_horizontal();
	_grid_size.y = _get_best_fit_amount_vertical();
	
	# NOTE: only works for vertical scroll
	_group_start_index = 1;
	
	_spawn_menu_items();
	
	await get_tree().process_frame;
	set_selected_index(0);


func _process(delta: float) -> void:
	# NOTE: only works for vertical scroll
	var percent = abs(_scroll_area.position.y) / (_scroll_area.size.y - container.size.y);
	
	var delta_pos = _scroll_area.position - _last_pos;
	
	if delta_pos.length() > 0:
		_reposition(Vector2(abs(delta_pos.x) / delta_pos.x, abs(delta_pos.y) / delta_pos.y));
	
	_last_pos = _scroll_area.position;


func get_selected_index() -> int:
	return _current_selected_index;


func set_selected_index(new_index : int):
	# NOTE: Only works for vertical
	_current_selected_index = new_index;
	
	var min_visible = (_group_start_index - 1) * _grid_size.x
	var max_visible = ((_group_start_index + _grid_size.y - 1) * _grid_size.x) - 1;
	
	# Check if item is currently in the visible range
	if _current_selected_index >= min_visible && _current_selected_index <= max_visible :
		var group_index = _item_index_to_group_index(new_index);
		var item_index = new_index % _grid_size.x;
		(_item_groups[group_index][item_index] as Control).grab_focus();
	# Scroll so that the item is in the visible range
	else:
		# Determine direction of the scroll
		var direction = Vector2(0, 1);
		if _current_selected_index > max_visible :
			direction = Vector2(0, -1);
		
		while !(_current_selected_index >= min_visible && _current_selected_index <= max_visible) :
			var orig_pos = _scroll_area.position;
			_scroll_area.position += (direction * (item_size + item_spacing))
			
			var delta_pos = _scroll_area.position - orig_pos;
			_reposition(Vector2(abs(delta_pos.x) / delta_pos.x, abs(delta_pos.y) / delta_pos.y));
			
			min_visible = (_group_start_index - 1) * _grid_size.x
			max_visible = ((_group_start_index + _grid_size.y - 1) * _grid_size.x) - 1;
		
		var group_index = _item_index_to_group_index(new_index);
		var item_index = new_index % _grid_size.x;
		(_item_groups[group_index][item_index] as Control).grab_focus();
		await get_tree().process_frame;
		container.ensure_control_visible((_item_groups[group_index][item_index] as Control));


func _item_index_to_group_index(index : int) -> int:
	# NOTE: Only works for vertical
	var group_index = 0;
	
	while ((group_index + _group_start_index) * _grid_size.x) <= index:
		group_index += 1;
	
	return group_index;


# Sets the data array to the provided array and recalculates bounds
func set_data(data : Array):
	_data = data;
	_total_item_count = data.size();
	
	# I miss ternary operators so much...
	_columns = 0;
	_rows = 0;
	
	if horizontal:
		_rows = min(_total_item_count, _grid_size.y);
		_columns = ceil((_total_item_count as float) / (_rows as float));
	else:
		_columns = min(_total_item_count, _grid_size.x);
		_rows = ceil((_total_item_count as float) / (_columns as float));
	
	var width = (item_size.x * _columns) + (item_spacing.x * (_columns - 1));
	var height = (item_size.y * _rows) + (item_spacing.y * (_rows - 1));
	
	_scroll_area.custom_minimum_size = Vector2(width, height);
	
	# NOTE: Likely only works vertically
	for i in _item_groups.size():
		_refresh_group(_item_groups[i], i);
	
	_refresh_group_wrap_navigation();


# Spawns the visible menu items
func _spawn_menu_items():
	_item_groups.clear();
	
	var primary = _grid_size.y;
	var secondary = _grid_size.x;
	
	if horizontal:
		primary = _grid_size.x;
		secondary = _grid_size.y;
	
	for p in primary:
		_item_groups.append([]);
		
		var p_pos = 0;
		
		if horizontal : p_pos = (p * item_size.x) + (p * item_spacing.x);
		else: p_pos = (p * item_size.y) + (p * item_spacing.y);
		
		for s in secondary:
			var s_pos = 0;
			
			if horizontal : s_pos = (s * item_size.y) + (s * item_spacing.y);
			else: s_pos = (s * item_size.x) + (s * item_spacing.x);
			
			# TODO: Define proper class for dynamic menu items?
			var item = menu_item.instantiate() as Control;
			item.custom_minimum_size = item_size;
			_scroll_area.add_child(item);
			
			var position = Vector2(s_pos, p_pos);
			if horizontal : position = Vector2(p_pos, s_pos);
			
			item.name = str(p) + "," + str(s);
			item.position = position;
			item.size = item_size;
			
			item.focus_entered.connect(_on_focus_entered);
			# TODO: Listen for when an item is clicked to fix the
			# known issue with erroneous wrapping(?)
			if item is Button :
				(item as Button).pressed.connect(_on_item_clicked);
			_item_groups[_item_groups.size() - 1].append(item);


func _on_focus_entered():
	_previous_selected_index = _current_selected_index;
	var focus = get_viewport().gui_get_focus_owner();
	
	for i in _item_groups.size():
		var index = _item_groups[i].find(focus);
		if index != -1:
			_current_group_index = i;
			_current_item_index = index;
	
	var group_amt = _grid_size.x;
	if horizontal: group_amt = _grid_size.y;
	
	_current_selected_index = (((_group_start_index - 1) + _current_group_index) * group_amt) + _current_item_index;
	
	# Check for wrap
	_check_wrap();
	
	# Item selected callbacks
	_on_item_selected();


func _on_item_selected():
	if _data.size() > 0 :
		on_item_selected.emit(_data[_current_selected_index]);


func _on_item_clicked():
	on_item_clicked.emit(_data[_current_selected_index]);


func _check_wrap():
	if (_data.size() <= _grid_size.x * _grid_size.y):
		return;
	# NOTE: Only works for vertical
	# Check for group
	var first_group_start_index = (_group_start_index - 1) * _grid_size.x;
	var first_group_end_index = (_group_start_index) * _grid_size.x;
	
	var in_first_group = _current_selected_index >= first_group_start_index && _current_selected_index < first_group_end_index;
	var out_first_group = _previous_selected_index < first_group_end_index;
	var in_last_group = _current_selected_index >= (_grid_size.y * _grid_size.x) - _grid_size.x;
	var out_last_group = _previous_selected_index >= floor(((_data.size() - 1) as float) / _grid_size.x) * _grid_size.x
	
	if out_first_group && in_last_group:
		_wrap_to_end();
	if in_first_group && out_last_group:
		_wrap_to_start();


func _wrap_to_start():
	# NOTE: Only works for vertical
	var _new_index = _previous_selected_index % _grid_size.x;
	set_selected_index(_new_index);


func _wrap_to_end():
	# NOTE: Only works for vertical
	var _new_index = floor(((_data.size() as float) / _grid_size.x)) * _grid_size.x + _previous_selected_index;
	set_selected_index(clampi(_new_index, 0, _data.size() - 1));


func _reposition(direction : Vector2):
	if direction.y != 0:
		_reposition_y(direction.y);
	else:
		_reposition_x(direction.x);
	
	_refresh_group_wrap_navigation();


func _reposition_y(direction : float):
	var root_pos = _scroll_area.position;
	var y_min = root_pos.y;
	var start_index = 0;
	var end_index = _item_groups.size() - 1;
	
	# Moving down
	if direction < 0:
		while _item_groups[start_index][0].position.y + item_size.y + item_spacing.y < abs(y_min) && _group_start_index <= _rows - _item_groups.size():
			var y_offset = _item_groups[end_index][0].position.y + item_size.y + item_spacing.y;
			
			for item in _item_groups[start_index]:
				item.position.y = y_offset;
			
			var group = _item_groups[start_index].duplicate();
			_item_groups.append(group);
			_item_groups.remove_at(start_index);
			
			_group_start_index += 1;
			
			_refresh_group(group, _group_start_index + end_index - 1)
	
	# Moving up
	else:
		while _item_groups[end_index][0].position.y > abs(y_min - container.size.y) && _group_start_index > 1:
			var y_offset = _item_groups[start_index][0].position.y - item_size.y - item_spacing.y;
			
			for item in _item_groups[end_index]:
				item.position.y = y_offset;
			
			var group = _item_groups[end_index].duplicate();
			_item_groups.insert(0, group);
			_item_groups.remove_at(end_index + 1);
			
			_group_start_index -= 1;
			
			_refresh_group(group, _group_start_index - 1)


func _reposition_x(direction : float):
	print("TODO");


func _get_best_fit_amount_horizontal() -> int:
	var amount : int = 0;
	var width : float = 0;
	
	while width < container.size.x:
		amount += 1;
		width += (item_size.x + item_spacing.x);
	
	if horizontal : 
		return amount + 1;
	else :
		return amount;


func _get_best_fit_amount_vertical() -> int:
	var amount : int = 0;
	var height : float = 0;
	
	while height < container.size.y:
		amount += 1;
		height += (item_size.y + item_spacing.y);
	
	if horizontal : 
		return amount;
	else :
		return amount + 1;


func _refresh_group(group : Array, row_index : int):
	# NOTE: Only works for vertical
	var index = row_index * _grid_size.x;
	
	for i in group.size():
		var item = group[i];
		
		if index < _data.size():
			item.visible = true;
			if (item as Object).has_method("refresh_data"):
				item.refresh_data(_data[index]);
		else :
			item.visible = false;
		
		# Release focus if this is not the selected index
		if index != _current_selected_index && get_viewport().gui_get_focus_owner() == (item as Control):
			(item as Control).release_focus();
		# Grab focus if this is the selected index
		# TODO: This fails when setting selection, fix later
		#if index == _current_selected_index && get_viewport().gui_get_focus_owner() != (item as Control):
		#	container.follow_focus = false;
		#	(item as Control).grab_focus();
		#	container.follow_focus = true;
		
		# Refresh navigation
		# NOTE: Only works for horizontal
		if index < _data.size() && i > 0:
			(item as Control).focus_neighbor_left = (group[i - 1] as Control).get_path();
			
			if i == group.size() - 1 || index == _data.size() - 1:
				(item as Control).focus_neighbor_right = (group[0] as Control).get_path();
				(group[0] as Control).focus_neighbor_left = (item as Control).get_path();
			else:
				(group[i - 1] as Control).focus_neighbor_right = (item as Control).get_path();
		else :
			(item as Control).focus_neighbor_left = "";
			(item as Control).focus_neighbor_right = "";
		
		index += 1;


func _refresh_group_wrap_navigation():
	# NOTE: Only works for vertical
	# Calculate last row index
	_last_group_index = _grid_size.y - 1;
	
	if _total_item_count < _grid_size.x * _grid_size.y:
		_last_group_index = floori(((_total_item_count - 1) as float) / _grid_size.x);
	
	# Get index of last valid item in the row:
	_last_item_index = _get_num_active_elements(_last_group_index) - 1;
	
	for i in _item_groups[0].size():
		var top_item = _item_groups[0][i] as Control;
		var bottom_item = _item_groups[_last_group_index][min(i, _last_item_index)] as Control;
		
		# Remove previous bottom and top wraps
		if _item_groups.size() > 1:
			(_item_groups[1][i] as Control).focus_neighbor_top = "";
			(_item_groups[_item_groups.size() - 2][i] as Control).focus_neighbor_bottom = "";
		
		top_item.focus_neighbor_top = bottom_item.get_path();
		if i <= _last_item_index :
			bottom_item.focus_neighbor_bottom = top_item.get_path();


func _get_num_active_elements(group : int) -> int:
	var result = 0;
	
	for item in _item_groups[group]:
		if (item as Control).visible : result += 1;
	
	return result;
