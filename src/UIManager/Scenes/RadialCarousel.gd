extends Control
class_name RadialCarousel;

@export var carousel_item : PackedScene;
@export var item_size : Vector2 = Vector2(100, 50);
@export var item_spacing_degrees : float = 10;
@export var carousel_size : Vector2 = Vector2(200, 200);
@export var carousel_offset : Vector2 = Vector2(0, 0);
@export var scroll_time : float = 0.1;
@export var jump_slots : int = 5;

var _process_input : bool = true;
var _scroll_delay : float = 0.05;

var _data : Array;
var _index : int = 0;
var _carousel_items : Array;
# Do we really need this?
var _visible_items : Array;

signal on_scroll();
signal on_item_highlighted(data);
signal on_item_clicked(data);


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if carousel_item != null :
		var angle : float = 0.0;
		
		while (angle < 360) :
			# TODO: Only spawn what is needed, like with the Dynamic Panel
			# Commented out values will assist with that
			#var pos = get_position_from_angle(angle);
			#var visible_x = (x_pos + (item_size.x / 2.0)) >= 0 && (x_pos - (item_size.x / 2.0)) <= size.x
			#var visible_y = (y_pos + (item_size.y / 2.0)) >= 0 && (y_pos - (item_size.y / 2.0)) <= size.y
			
			var item = carousel_item.instantiate() as Control;
			if !(item is RadialCarouselItem):
				print("ERROR: Item is of invalid type.")
				item.queue_free();
				return;
			
			add_child(item);
			item.custom_minimum_size = item_size;
			item.size = item_size;
			
			item.owning_carousel = self;
			item.set_intended_angle(angle);
			item.set_angle(angle);
			
			var x_off_screen = item.position.x + item_size.x < 0 || item.position.x > size.x
			var y_off_screen = item.position.y + item_size.x < 0 || item.position.y > size.y
			
			if !x_off_screen && !y_off_screen : _visible_items.append(item);
			
			_carousel_items.append(item);
			angle += item_spacing_degrees;
	
	#set_data(["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"])
	#self.grab_focus();


func set_data(data : Array) :
	_data = data;
	_redraw_items();


func get_data_size() -> int:
	return _data.size();


func set_index(index : int) :
	_index = index;
	_redraw_items();


func _redraw_items() :
	if _data.size() < 1 :
		self.visible = false;
		return;
	
	self.visible = true;
	var span = _carousel_items.size() / 2;
	
	#if _data.size() < _visible_items.size():
	#	print("This is where the fun begins")
	#	return;
	
	var current_index = _index;
	for i in range(0, span):
		if current_index >= _data.size():
			current_index = 0;
		
		_carousel_items[i].set_data(_data[current_index]);
		current_index += 1;
		
		_carousel_items[i].set_highlight(i==0);
	
	current_index = _index - 1;
	for i in range(span * 2, span, -1):
		if current_index < 0:
			current_index = _data.size() - 1;
		
		_carousel_items[i - 1].set_data(_data[current_index]);
		current_index -= 1;
		
		_carousel_items[i - 1].set_highlight(i-1==0);
	
	if _index < _data.size() && _index >= 0:
		on_item_highlight(_data[_index]);


func on_item_highlight(data):
	on_item_highlighted.emit(_data[_index])
	pass;


func get_position_from_angle(angle : float) -> Vector2:
	var x_pos = (cos(deg_to_rad(angle)) * carousel_size.x) - (item_size.x / 2.0) + carousel_offset.x;
	var y_pos = (sin(deg_to_rad(angle)) * carousel_size.y) + (size.y / 2.0) - (item_size.y / 2.0) + carousel_offset.y;
	
	return Vector2(x_pos, y_pos);


func _scroll_ui(direction : int) :
	if _data.size() <= 1 : return
	
	on_scroll_begin();
	
	_index -= direction;
	if _index < 0 : _index = _data.size() - 1;
	if _index >= _data.size() : _index = 0;
	
	if direction < 0 : 
		var item = _carousel_items.pop_front();
		_carousel_items.push_back(item);
	else : 
		var item = _carousel_items.pop_back();
		_carousel_items.push_front(item);
	
	var has_refreshed = false;
	
	# TODO: add method to kill all tweens if the tween is still in motion
	for item in _carousel_items:
		var angle = item.get_intended_angle();
		var new_angle = angle + (item_spacing_degrees * direction);
		var start_angle = item.get_angle();
		
		var tween = get_tree().create_tween();
		tween.tween_method((item as RadialCarouselItem).set_angle, start_angle, new_angle, scroll_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		
		if !has_refreshed:
			has_refreshed = true;
			tween.finished.connect(_redraw_items);
			item.set_highlight(false);
		else :
			item.set_highlight(false);
		
		item.set_intended_angle(new_angle)


func on_scroll_begin():
	on_scroll.emit();


func _unhandled_input(event : InputEvent):
	if !_process_input || get_data_size() == 0: return;
	
	if event.is_action_pressed("ui_up") || (event.is_action("ui_up") && event.is_echo()):
		_scroll_ui(1);
		accept_event();
		
		_process_input = false;
		await get_tree().create_timer(_scroll_delay).timeout
		_process_input = true;
	
	if event.is_action_pressed("ui_down") || (event.is_action("ui_down") && event.is_echo()):
		_scroll_ui(-1);
		accept_event();
		
		_process_input = false;
		await get_tree().create_timer(_scroll_delay).timeout
		_process_input = true;
	
	if event.is_action_pressed("ui_right") && !(event.is_action("ui_down") || event.is_action("ui_up")):
		for i in jump_slots:
			_scroll_ui(-1);
			accept_event();
	
	if event.is_action_pressed("ui_left") && !(event.is_action("ui_down") || event.is_action("ui_up")):
		for i in jump_slots:
			_scroll_ui(1);
			accept_event();
	
	if event.is_action_pressed("ui_accept"):
		on_item_selected(_data[_index]);
		accept_event();


func on_item_selected(data):
	on_item_clicked.emit(data);
	pass;
