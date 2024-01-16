extends AnimationSequenceAction

class_name ASAChangeAnimation

@export var target : AnimationSequenceAction.Target;
@export var effect_index : int;
@export var animation_name : String;

func execute(sequence : AnimationSequence):
	var entity : EntityBase;
	if target == Target.USER:
		entity = sequence.user;
	elif target == Target.TARGET:
		entity = sequence.target[sequence.target_index];
	else:
		entity = sequence.effects[effect_index];
	
	entity.animator.play(animation_name);
