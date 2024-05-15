extends Control
class_name UnderlayBar

enum AnimationType { Smooth, Delayed };

@onready var background : Control = $BarBackground;
@onready var fill : Control = $BarBackground/BarFill;
@onready var underlay : Control = $BarBackground/BarUnderlay;
@onready var text : Control = $BarBackground/TextRoot/Text;

@export var start_value : float = 50;
@export var min_value : float = 0;
@export var max_value : float = 100;
## The format used for text display. Put the current and max values in curly brackets.
@export var text_format : String = "{current}/{max}";
@export var round_to_whole_number : bool= true;
@export var use_underlay : bool = true;
@export var deplete_color : Color;
@export var refill_color : Color;
@export var animation_type : AnimationType = AnimationType.Smooth;
@export var bar_subtract_speed : float = 1;
@export var trailing_zeroes : bool = false;

var current_value : float = 0;
var fill_tween : Tween;


func _ready():
	underlay.visible = false;
	
	_validate_max_value();
	set_value_immediate(start_value);


func _validate_max_value():
	if max_value < min_value : 
		push_error("ERROR: Max value is less than min value.");
		max_value = min_value;


func set_values_immediate(current : float, min : float, max : float):
	min_value = min;
	max_value = max;
	_validate_max_value();
	
	set_value_immediate(current);


func _set_text(value : float):
	var current_str = str(value);
	var max_str = str(max_value);
	
	while current_str.length() < 3 :
		if trailing_zeroes : 
			current_str = "0" + current_str;
		else:
			current_str = " " + current_str;
	
	while max_str.length() < 3 :
		if trailing_zeroes : 
			max_str = "0" + max_str;
		else:
			max_str = " " + max_str;
	
	text.text = tr(text_format).format({current = current_str, max = max_str});


func set_value_immediate(val : float):
	# Calculate fill amount
	current_value = clamp(val, min_value, max_value);
	var percent = ((current_value - min_value) / (max_value - min_value));
	
	# Set fill amount
	fill.scale.x = percent;
	underlay.scale.x = percent;
	
	# Display output
	if "text" in text :
		_set_text(current_value);


func set_value(val : float):
	# Set up underlay
	if use_underlay : 
		underlay.visible = true;
		underlay.scale.x = fill.scale.x;
		
		if val > current_value : underlay.color = refill_color;
		else : underlay.color = deplete_color;
	
	# Calculate new scale
	var old_percent = fill.scale.x;
	current_value = clamp(val, min_value, max_value);
	var percent = ((current_value - min_value) / (max_value - min_value));
	
	# Kill any active tweens
	if fill_tween != null && fill_tween.is_running() : fill_tween.kill();
	
	# Calculate tween duration
	var duration = 0.0;
	if bar_subtract_speed != 0 : duration = 1.0 / bar_subtract_speed;
	
	# Create tweens
	fill_tween = get_tree().create_tween();
	fill_tween.set_parallel(true);
	
	match animation_type:
		AnimationType.Smooth:
			fill_tween.tween_callback(_on_fill_bar_complete).set_delay(duration);
			fill_tween.tween_method(_update_text, old_percent, percent, duration)
			
			var property = fill_tween.tween_property(fill, "scale:x", percent, duration);
			property.set_ease(Tween.EASE_OUT);
			property.set_trans(Tween.TRANS_CUBIC);
		AnimationType.Delayed:
			_set_text(val); 
			fill.scale.x = percent;
			fill_tween.tween_callback(_on_fill_bar_complete).set_delay(duration);


func _update_text(value : float):
	var amt = value * (max_value - min_value);
	
	if round_to_whole_number: _set_text(roundi(amt)); 
	else :_set_text(amt); 


func _on_fill_bar_complete():
	underlay.visible = false;


func set_bar_visible(val : bool):
	background.visible = val;


func set_text_visible(val : bool):
	text.visible = val;
