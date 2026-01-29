@tool
extends Area2D
class_name ZLightReceiver

const MAX_LIGHTS_PER_OBJECT : int = 8;

@onready var collider : CollisionShape2D = $CollisionShape2D;

@export var shape : Shape2D :
	set(value):
		if value is RectangleShape2D || value == null :
			shape = value;
			
			if collider == null :
				return;
			
			collider.shape = shape;
			_setup_shape_size();
		else :
			print("ERROR: Unsupported shape type!")


@export var size : Vector2 = Vector2(50.0, 50.0) :
	set(value) :
		if value.x < 0 : value.x = 0;
		if value.y < 0 : value.y = 0;
		
		size = value;
		
		_setup_shape_size();


@export var origin_offset : Vector2;

@export var static_receiver : bool = true;
@export var debug : bool = false;

var _mat : ShaderMaterial;
var _lights : Array[ZLight];
var _sprite : Sprite2D;

var _current_pos : Vector2;


func _setup_shape_size() :
	if shape != null :
		if shape is RectangleShape2D :
			(shape as RectangleShape2D).size = size;


func _ready() -> void:
	process_mode == ProcessMode.PROCESS_MODE_INHERIT;
	
	collider.shape = shape;
	
	if (get_parent() is Sprite2D) :
		_sprite = (get_parent() as Sprite2D);
	
	if !Engine.is_editor_hint() :
		if _sprite != null :
			_mat = _sprite.material.duplicate() as ShaderMaterial;
			(get_parent() as CanvasItem).material = _mat;
			_current_pos = get_global_transform_with_canvas().origin;
			_set_material_params();


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() : return;
	
	if !static_receiver :
		var dist = _current_pos.distance_squared_to(global_position);
		
		if dist > 0 :
			_set_material_params();
			_current_pos = get_global_transform_with_canvas().origin;
	else :
		_set_material_params();


func _set_material_params() :
	if _mat == null : return;
	
	# Define origin point for light in screenspace
	var screen_pos = get_global_transform_with_canvas().origin;
	
	_mat.set_shader_parameter("origin", (screen_pos + origin_offset));
	#_mat.set_shader_parameter("falloff_y", falloff_y);
	#print("SCREEN POS: " + str((screen_pos + origin_offset)) + _sprite.get_parent().name)
	
	# Calculate light parameters
	var light_origins : Array[Vector2];
	var light_is_circle : Array[bool];
	var light_size : Array[Vector2];
	var light_color : Array[Color];
	var light_energy : Array[float];
	var light_falloff : Array[Vector2];
	var is_shadow : Array[bool];
	
	for i in MAX_LIGHTS_PER_OBJECT :
		if i < _lights.size() :
			var light = _lights[i];
			var light_screen_pos = light.get_global_transform_with_canvas().origin;
			#print(str(light_screen_pos) + " " + light.name)
			#print(light.get_size())
			#print(light.get_falloff())
			
			light_origins.append(light_screen_pos);
			light_is_circle.append(light.shape is CircleShape2D);
			light_size.append(light.get_size());
			light_color.append(light.color);
			light_energy.append(light.energy);
			light_falloff.append(light.get_falloff());
			is_shadow.append(light.is_shadow);
		else :
			light_origins.append(Vector2.ZERO);
			light_is_circle.append(false);
			light_size.append(Vector2.ZERO);
			light_color.append(Color.TRANSPARENT);
			light_energy.append(0.0);
			light_falloff.append(Vector2.ZERO);
			is_shadow.append(false);
	
	if debug :
		print(light_size);
		print(light_falloff);
	
	_mat.set_shader_parameter("light_origins", light_origins);
	_mat.set_shader_parameter("light_is_circle", light_is_circle);
	_mat.set_shader_parameter("light_size", light_size);
	_mat.set_shader_parameter("light_color", light_color);
	_mat.set_shader_parameter("light_energy", light_energy);
	_mat.set_shader_parameter("light_falloff", light_falloff);
	_mat.set_shader_parameter("shadow", is_shadow);
	
	# Set active light count
	_mat.set_shader_parameter("active_zlights", min(_lights.size(), MAX_LIGHTS_PER_OBJECT));


func _on_area_entered(area: Area2D) -> void:
	if area is ZLight && _lights.size() < MAX_LIGHTS_PER_OBJECT:
		_lights.append(area as ZLight);
		(area as ZLight).on_light_updated.connect(_set_material_params);
		_set_material_params();


func _on_area_exited(area: Area2D) -> void:
	if area is ZLight && _lights.has(area as ZLight):
		_lights.erase(area as ZLight);
		(area as ZLight).on_light_updated.disconnect(_set_material_params);
		_set_material_params();
