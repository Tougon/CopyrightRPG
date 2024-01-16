extends AnimationSequenceAction

class_name ASAChangeAnimationSpeed

@export var target : AnimationSequenceAction.Target;
@export var animation_speed : float;

func execute(sequence : AnimationSequence):
	var entity : EntityController;
	if target == Target.USER:
		entity = sequence.user;
	else:
		entity = sequence.target[sequence.target_index];
	
	entity.animator.speed_scale = animation_speed;
