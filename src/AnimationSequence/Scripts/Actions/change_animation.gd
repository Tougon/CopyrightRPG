extends AnimationSequenceAction

class_name ASAChangeAnimation

@export var target : AnimationSequenceAction.Target;
@export var animation_name : String;

func execute(sequence : AnimationSequence):
	var entity : EntityController;
	if target == Target.USER:
		entity = sequence.user;
	else:
		entity = sequence.target[sequence.target_index];
	
	entity.animator.play(animation_name);
