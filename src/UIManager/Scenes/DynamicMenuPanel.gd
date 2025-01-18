# Should this even inherit from menu panel? I don't think it should, personally
extends Panel

@export var container : ScrollContainer;
@export var menu_item: PackedScene
@export var item_size : Vector2 = Vector2(75.0, 75.0);
@export var item_spacing : Vector2 = Vector2(10.0, 10.0);
@export var horizontal : bool = false;

# Test Variables
var _data : Array;
# End Test Variables

var _grid_size : Vector2i;
var _columns : int;
var _rows : int;
var _scroll_area : Control;
var _item_groups : Array[Array];
var _total_item_count : int;

var _last_pos : Vector2;
var _group_start_index : int;
var _current_scroll_percent : float;

var _current_selected_index : int = -1;

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
	
	# Test Code, Delete This
	_set_data(["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]);
	# End Test Code


func _process(delta: float) -> void:
	# NOTE: only works for vertical scroll
	var percent = abs(_scroll_area.position.y) / (_scroll_area.size.y - container.size.y);
	
	var delta_pos = _scroll_area.position - _last_pos;
	
	if delta_pos.length() > 0:
		reposition(Vector2(abs(delta_pos.x) / delta_pos.x, abs(delta_pos.y) / delta_pos.y));
	
	_last_pos = _scroll_area.position;


# Sets the data array to the provided array and recalculates bounds
func _set_data(data : Array):
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


# Spawns the visible menu items
func _spawn_menu_items():
	_item_groups.clear();
	
	var primary = _grid_size.x;
	var secondary = _grid_size.y;
	
	if horizontal:
		primary = _grid_size.y;
		secondary = _grid_size.x;
	
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
			
			_item_groups[_item_groups.size() - 1].append(item);





func reposition(direction : Vector2):
	if direction.y != 0:
		reposition_y(direction.y);
	else:
		reposition_x(direction.x);


func reposition_y(direction : float):
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


func reposition_x(direction : float):
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
		if (item as Object).has_method("refresh_data"):
			if index < _data.size():
				item.visible = true;
				item.refresh_data(_data[index]);
			else:
				item.visible = false;
		
		# TEMP CODE:
		if index < _data.size():
			item.visible = true;
			item.text = _data[index];
		else :
			item.visible = false;
		# END TEMP CODE:
		
		# Refresh navigation
		# NOTE: Only works for horizontal
		if index < _data.size() && i > 0:
			(item as Control).focus_neighbor_left = (group[i - 1] as Control).get_path();
			
			if i == group.size() - 1 || index == _data.size() - 1:
				if index == _data.size() - 1:
					print("YES");
				(item as Control).focus_neighbor_right = (group[0] as Control).get_path();
				(group[0] as Control).focus_neighbor_left = (item as Control).get_path();
			else:
				(group[i - 1] as Control).focus_neighbor_right = (item as Control).get_path();
		else :
			(item as Control).focus_neighbor_left = "";
			(item as Control).focus_neighbor_right = "";
		
		index += 1;
