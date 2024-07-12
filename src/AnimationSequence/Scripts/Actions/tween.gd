extends AnimationSequenceAction

class_name ASATween

@export var use_directionality : bool;
@export var target : AnimationSequenceAction.Target;
@export var effect_index : int;
@export var tween : TweenFrame;
@export var override_defeated : bool = false;
@export var relative_to_object : bool = false;
@export var relative_object_type : AnimationSequenceAction.Target;
@export var relative_effect_index : int;
@export var relative_amount : float = 1.0;

func execute(sequence : AnimationSequence):
	var entity : EntityBase;
	if target == Target.USER:
		entity = sequence.user;
	elif target == Target.TARGET:
		# Only tween the target if they aren't currently animating (defeat)
		if sequence.target[sequence.target_index].current_entity.type == Entity.Type.GENERIC && (!sequence.target[sequence.target_index].is_defeated || override_defeated):
			entity = sequence.target[sequence.target_index];
	elif target == Target.EFFECT && effect_index < sequence.effects.size():
		entity = sequence.effects[effect_index];
	
	if entity == null : return;
	
	var tween_target = entity.get_node(NodePath(tween.target));
	# Check if the target is valid. If so, add this frame to the tween
	if tween_target == null:
		return;
	else:
		if tween.material_property:
			tween_target = tween_target.material;
	
	var current_tween = sequence.tree.create_tween();
	current_tween.set_parallel(true);
	
	var value = tween.get_value();
	
	if relative_object_type && value is Vector2:
		var relative_target : EntityBase
		
		if relative_object_type == Target.USER:
			relative_target = sequence.user;
		elif relative_object_type == Target.TARGET:
			relative_target = sequence.target[sequence.target_index];
		else:
			relative_target = sequence.effects[relative_effect_index];
		
		if relative_target != null:
			value = (relative_target.global_position - entity.global_position) * relative_amount;
	
	if use_directionality:
		if value is float || value is int:
			value *= sequence.direction_x;
		if value is Vector2:
			value.x *= sequence.direction_x;
			value.y *= sequence.direction_y;
	
	var property = current_tween.tween_property(tween_target, tween.property_name, value, tween.duration);
	
	if property == null:
		return;
	
	property.set_trans(tween.transition)
	property.set_ease(tween.ease)
	property.set_delay(tween.delay);
	
	if tween.relative:
		property.as_relative();
	
	if tween.use_from:
		property.from(tween.get_value_from());
