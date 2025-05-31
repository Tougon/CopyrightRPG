extends AnimationSequenceAction

class_name ASAGenerateEffect

@export_file("*.tscn") var effect_scene_path: String;
@export var relative : AnimationSequenceAction.Target;
@export var effect_index : int;
@export var effect_position : Vector2;
@export var effect_layer : int;
@export var effect_rotation : float;
@export var effect_scale : Vector2 = Vector2(1, 1);
@export var child : bool;
@export var pos_match_sequence_dir : bool;
@export var rot_match_sequence_dir : bool;
@export var scl_match_sequence_dir_x : bool;
@export var scl_match_sequence_dir_y : bool;
@export var effect_variance : Vector2;

var effect_scene : PackedScene;

func warmup():
	if ResourceLoader.exists(effect_scene_path, "PackedScene"):
		ResourceLoader.load_threaded_request(effect_scene_path, "PackedScene")


func execute(sequence : AnimationSequence):
	# Spawn the effect
	var result = ResourceLoader.load_threaded_get_status(effect_scene_path);
	
	if result == ResourceLoader.THREAD_LOAD_LOADED:
		effect_scene = ResourceLoader.load_threaded_get(effect_scene_path) as PackedScene;
	
	if effect_scene == null:
		print("ERROR: Failed to load effect at " + effect_scene_path)
		return;
	
	var effect = effect_scene.instantiate() as EntityBase;
	var position = effect_position;
	
	# Determine effect position
	var entity : EntityBase;
	if relative == Target.USER:
		entity = sequence.user;
	elif relative == Target.TARGET:
		entity = sequence.target[sequence.target_index];
	elif relative == Target.EFFECT && effect_index < sequence.effects.size() && effect_index >= 0:
		entity = sequence.effects[effect_index];
	
	if entity != null:
		
		if pos_match_sequence_dir :
			position.x = entity.global_position.x + (effect_position.x * sequence.direction_x);
			position.y = entity.global_position.y + (effect_position.y * sequence.direction_y);
		else : 
			position.x = entity.global_position.x + effect_position.x;
			position.y = entity.global_position.y + effect_position.y;
		
		if child :
			entity.add_child(effect);
	
	effect.z_index = effect_layer;
	effect.z_as_relative = false;
	
	if !child : 
		sequence.root.add_child(effect);
	
	var variance = effect_variance * 0.5;
	var offset = Vector2(randf_range(-variance.x, variance.x), randf_range(-variance.y, variance.y));
	var scale = Vector2(effect_scale.x * sequence.direction_x, effect_scale.y * sequence.direction_y)
	
	effect.global_position = position + offset;
	
	if rot_match_sequence_dir : effect.rotation = effect_rotation * sequence.direction_x;
	else : effect.rotation = effect_rotation;
	
	var inst_scale = effect_scale;
	if scl_match_sequence_dir_x : inst_scale.x = scale.x;
	if scl_match_sequence_dir_y : inst_scale.y = scale.y;
	effect.scale = inst_scale;
	
	sequence.effects.append(effect);
	effect.reset_physics_interpolation();


func cooldown():
	effect_scene = null;
