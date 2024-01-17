extends AnimationSequenceAction

class_name ASAEndLoop

func execute(sequence : AnimationSequence):
	var current_loop = sequence.loops[sequence.loops.size() - 1];
	current_loop.num_iterations += 1;
	
	if current_loop.num_iterations < current_loop.num_loops:
		sequence.current_frame = current_loop.start_frame;
	else:
		sequence.loops.erase(current_loop);
	
	sequence.looping = sequence.loops.size() > 0;

func ignore_on_success() -> bool:
	return true;
