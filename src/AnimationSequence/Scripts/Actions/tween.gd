extends AnimationSequenceAction

class_name ASATween

@export var target : AnimationSequenceAction.Target;
@export var tween : TweenFrame;

func execute(sequence : AnimationSequence):
	var entity : EntityController;
	if target == Target.USER:
		entity = sequence.user;
	else:
		entity = sequence.target[sequence.target_index];
	
	var tween_target = entity.get_node(NodePath(tween.target));
	# Check if the target is valid. If so, add this frame to the tween
	if tween_target == null:
		return;
	else:
		if tween.material_property:
			tween_target = tween_target.material;
	
	var current_tween = sequence.tree.create_tween();
	current_tween.set_parallel(true);
	
	var property = current_tween.tween_property(tween_target, tween.property_name, tween.get_value(), tween.duration);
	
	if property == null:
		return;
	
	property.set_trans(tween.transition)
	property.set_ease(tween.ease)
	property.set_delay(tween.delay);
	
	if tween.relative:
		property.as_relative();
	
	if tween.use_from:
		property.from(tween.get_value_from());
