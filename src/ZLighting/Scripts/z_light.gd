@tool
extends Area2D
class_name ZLight

const UNIT_SCALE : float = 100.0;
const FALLOFF_SCALE : float = 10.0;

signal on_light_updated();

@onready var collider : CollisionShape2D = $CollisionShape2D;
@onready var falloff_prev : CollisionShape2D = $FalloffPrev;

@export var is_shadow : bool = false;

@export var shape : Shape2D :
	set(value):
		if value is CircleShape2D || value is RectangleShape2D || value == null :
			shape = value;
			
			if collider == null :
				return;
			
			collider.shape = shape;
			_setup_shape_size();
			_setup_falloff_prev();
		else :
			print("ERROR: Unsupported shape type!")


@export var size : Vector2 = Vector2(1.0, 1.0) :
	set(value) :
		if value.x < 0 : value.x = 0;
		if value.y < 0 : value.y = 0;
		
		size = value;
		
		_setup_shape_size();
		
		_setup_falloff_prev();


@export var color : Color = Color.WHITE :
	set(value) :
		color = value;
		on_light_updated.emit();

@export var color_pulse : Gradient;
@export var color_pulse_speed : float = 1.0;


@export var energy : float = 1.0 :
	set(value) :
		energy = value;
		on_light_updated.emit();

@export var energy_pulse : Curve; 
@export var energy_pulse_speed : float = 1.0;

@export var falloff : float = 0.0 :
	set(value) :
		if value < 0 : value = 0;
		var scale = 0;
		
		if shape is CircleShape2D :
			scale = (shape as CircleShape2D).radius;
		if shape is RectangleShape2D :
			scale = max((shape as RectangleShape2D).size.x, (shape as RectangleShape2D).size.y);
		
		if (value * FALLOFF_SCALE) >= scale :
			_setup_falloff_prev();
			return;
		
		falloff = value;
		_setup_falloff_prev();
		# ZLIGHT_TBD: Runtime falloff changes 


var _falloff_prev : Shape2D;

var _energy_max : float;
var _energy_time : float = 0;
var _color_time : float = 0;


func _ready() -> void:
	if !Engine.is_editor_hint() :
		falloff_prev.disabled = true;
		falloff_prev.visible = false;
	
	collider.shape = shape;
	
	_setup_shape_size();
	_setup_falloff_prev();
	
	_energy_max = energy;


func _process(delta: float) -> void:
	if !Engine.is_editor_hint() :
		if energy_pulse != null && energy_pulse_speed > 0 :
			_energy_time += delta * energy_pulse_speed;
			if _energy_time > 1.0 :
				_energy_time -= 1.0;
			
			energy = energy_pulse.sample(_energy_time) * _energy_max;
		
		if color_pulse != null && color_pulse_speed > 0 :
			_color_time += delta * color_pulse_speed;
			if _color_time > 1.0 :
				_color_time -= 1.0;
			
			color = color_pulse.sample(_color_time);


func get_size() -> Vector2:
	if shape is CircleShape2D :
		return Vector2(max(size.x, size.y) * UNIT_SCALE, max(size.x, size.y) * UNIT_SCALE);
	return size * UNIT_SCALE;


func get_falloff() -> Vector2:
	if _falloff_prev is CircleShape2D :
		var radius = (shape as CircleShape2D).radius;
		radius -= (falloff * FALLOFF_SCALE);
		return Vector2(radius, radius)
	
	if _falloff_prev is RectangleShape2D :
		var size = (shape as RectangleShape2D).size;
		var percent = (max(size.x, size.y) - (falloff * FALLOFF_SCALE)) / max(size.x, size.y);
		return (size * percent);
	
	return Vector2.ZERO;


func _setup_shape_size() :
	if shape != null :
		if shape is CircleShape2D :
			(shape as CircleShape2D).radius = max(size.x, size.y) * UNIT_SCALE;
			_falloff_prev = CircleShape2D.new();
		
		if shape is RectangleShape2D :
			(shape as RectangleShape2D).size = size * UNIT_SCALE;
			_falloff_prev = RectangleShape2D.new();



func _setup_falloff_prev() :
	if !Engine.is_editor_hint() :
		return;
	
	if shape == null : 
		if _falloff_prev != null : 
			_falloff_prev = null;
			return;
	
	if _falloff_prev is CircleShape2D :
		var radius = (shape as CircleShape2D).radius;
		radius -= (falloff * FALLOFF_SCALE);
		(_falloff_prev as CircleShape2D).radius = radius;
	
	if _falloff_prev is RectangleShape2D :
		var size = (shape as RectangleShape2D).size;
		var percent = (max(size.x, size.y) - (falloff * FALLOFF_SCALE)) / max(size.x, size.y);
		(_falloff_prev as RectangleShape2D).size = (size * percent)
	
	if falloff_prev != null :
		falloff_prev.shape = _falloff_prev;
