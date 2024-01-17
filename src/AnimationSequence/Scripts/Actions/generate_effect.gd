extends AnimationSequenceAction

class_name ASAGenerateEffect

@export var effect_scene : PackedScene;
@export var relative : AnimationSequenceAction.Target;
@export var effect_position : Vector2;
@export var effect_rotation : float;
@export var effect_scale : Vector2;
@export var child : bool;
@export var match_scale : bool;
@export var effect_variance : Vector2;

# TODO: Z-axis (layering)

func execute(sequence : AnimationSequence):
	# Spawn the effect
	var effect = effect_scene.instantiate() as EntityBase;
	var position = effect_position;
	
	# Determine effect position
	var entity : EntityBase;
	if relative == Target.USER:
		entity = sequence.user;
	elif relative == Target.TARGET:
		entity = sequence.target[sequence.target_index];
	
	if entity != null:
		position.x = entity.global_position.x + (effect_position.x * sequence.direction_x);
		position.y = entity.global_position.y + (effect_position.y * sequence.direction_y);
		
		if child :
			entity.add_child(effect);
	
	if !child : 
		sequence.root.add_child(effect);
	
	var variance = effect_variance * 0.5;
	var offset = Vector2(randf_range(-variance.x, variance.x), randf_range(-variance.y, variance.y));
	var scale = Vector2(effect_scale.x * sequence.direction_x, effect_scale.y * sequence.direction_y)
	
	effect.global_position = position + offset;
	effect.rotation = effect_rotation * sequence.direction_x;
	
	if match_scale : effect.scale = scale;
	else : effect.scale = effect_scale;
	
	sequence.effects.append(effect);
