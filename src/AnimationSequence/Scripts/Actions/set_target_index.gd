extends AnimationSequenceAction

class_name ASASetTargetIndex

@export var index : int;
@export var set_to_loop : bool = false;

func execute(sequence : AnimationSequence):
	if set_to_loop : sequence.target_index = sequence.loops[sequence.loops.size() - 1].num_iterations;
	else : sequence.target_index = index;
