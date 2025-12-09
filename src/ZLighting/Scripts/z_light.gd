@tool
extends Area2D
class_name ZLight

const UNIT_SCALE : float = 100.0;
const FALLOFF_SCALE : float = 10.0;

@onready var collider : CollisionShape2D = $CollisionShape2D;
@onready var falloff_prev : CollisionShape2D = $FalloffPrev;

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
		# ZLIGHT_TBD: Runtime color changes


@export var energy : float = 1.0 :
	set(value) :
		energy = value;
		# ZLIGHT_TBD: Runtime energy changes 


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


func _ready() -> void:
	if !Engine.is_editor_hint() :
		falloff_prev.disabled = true;
		falloff_prev.visible = false;
	
	collider.shape = shape;
	
	_setup_shape_size();
	_setup_falloff_prev();


func _process(delta: float) -> void:
	pass;


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
