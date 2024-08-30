extends EntityBase
class_name EntitySprite

@onready var sprite : Sprite2D = $Sprite2D;
@onready var animator : AnimationPlayer = $AnimationPlayer;
@onready var tween : TweenPlayer = $TweenPlayer;
var mat = ShaderMaterial;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instance the sprite's material
	mat = sprite.material.duplicate() as ShaderMaterial;
	sprite.material = mat;


func _reset_shader_parameters():
	if mat != null :
		mat.set_shader_parameter("overlay_color", Color.WHITE);
		mat.set_shader_parameter("overlay_color_amount", 0.0);
		mat.set_shader_parameter("overlay_alpha_amount", 0.0);
		mat.set_shader_parameter("overlay_texture_amount", 0.0);


# Visual control
func set_entity_sprite(sprite : Texture2D):
	self.sprite.texture = sprite;


func set_overlay_sprite(sprite : Texture2D):
	mat.set_shader_parameter("overlay_texture", sprite);


func get_entity_material():
	return mat;


func get_sprite():
	return sprite;


func get_sprite_top_offset():
	
	if sprite == null: return Vector2(0,0);
	
	var min = Vector2(-sprite.texture.get_width() / 2, -sprite.texture.get_height() / 2);
	var max = Vector2(sprite.texture.get_width() / 2, sprite.texture.get_height() / 2);
	
	# I hate that I have to do this, but normal nested loops do not work.
	var y = min.y;
	
	while y <= max.y:
		var x = min.x;
		while x <= max.x:
			if sprite.is_pixel_opaque(Vector2(x, y)):
				return Vector2(x, y)
			x += 1;
		y += 1;
	
	return Vector2(0,0);


# Animation control
func set_animation(val : String):
	animator.play(val);


func frame_speed_modify(speed : float):
	animator.speed_scale = speed;


# Tween control
func set_color_tween(color_tween: TweenFrame, amt_tween: TweenFrame):
	# Create the tween instance and set parallel
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	
	if color_tween != null && color_tween.value_type == TweenFrame.ValueType.COLOR:
		
		var property = tween.tween_property(mat, "shader_parameter/overlay_color", color_tween.get_value(), color_tween.duration);
		property.set_trans(color_tween.transition)
		property.set_ease(color_tween.ease)
		property.set_delay(color_tween.delay);
		
		if color_tween.relative:
			property.as_relative();
		
		if color_tween.use_from:
			property.from(color_tween.get_value_from());
	
	if amt_tween != null && amt_tween.value_type == TweenFrame.ValueType.FLOAT:
		
		var property = tween.tween_property(mat, "shader_parameter/overlay_color_amount", amt_tween.get_value(), amt_tween.duration);
		property.set_trans(amt_tween.transition)
		property.set_ease(amt_tween.ease)
		property.set_delay(amt_tween.delay);
		
		if amt_tween.relative:
			property.as_relative();
		
		if amt_tween.use_from:
			property.from(amt_tween.get_value_from());


func set_overlay_tween(offset_tween: TweenFrame, tiling_tween: TweenFrame, amt_tween: TweenFrame):
	# Create the tween instance and set parallel
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	
	if offset_tween != null && offset_tween.value_type == TweenFrame.ValueType.VECTOR2:
		
		var property = tween.tween_property(mat, "shader_parameter/overlay_texture_offset", offset_tween.get_value(), offset_tween.duration);
		property.set_trans(offset_tween.transition)
		property.set_ease(offset_tween.ease)
		property.set_delay(offset_tween.delay);
		
		if offset_tween.relative:
			property.as_relative();
		
		if offset_tween.use_from:
			property.from(offset_tween.get_value_from());
	
	if tiling_tween != null && tiling_tween.value_type == TweenFrame.ValueType.VECTOR2:
		
		var property = tween.tween_property(mat, "shader_parameter/overlay_texture_tiling", tiling_tween.get_value(), tiling_tween.duration);
		property.set_trans(tiling_tween.transition)
		property.set_ease(tiling_tween.ease)
		property.set_delay(tiling_tween.delay);
		
		if tiling_tween.relative:
			property.as_relative();
		
		if tiling_tween.use_from:
			property.from(tiling_tween.get_value_from());
	
	if amt_tween != null && amt_tween.value_type == TweenFrame.ValueType.FLOAT:
		
		var property = tween.tween_property(mat, "shader_parameter/overlay_texture_amount", amt_tween.get_value(), amt_tween.duration);
		property.set_trans(amt_tween.transition)
		property.set_ease(amt_tween.ease)
		property.set_delay(amt_tween.delay);
		
		if amt_tween.relative:
			property.as_relative();
		
		if amt_tween.use_from:
			property.from(amt_tween.get_value_from());
