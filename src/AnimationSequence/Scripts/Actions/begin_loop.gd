extends AnimationSequenceAction

class_name ASABeginLoop

@export var num_loops : int;
@export var loop_targets : bool;

func execute(sequence : AnimationSequence):
	if loop_targets : 
		num_loops = sequence.target.size();
	
	var loop = AnimationSequenceLoop.new(sequence.current_frame, num_loops);
	sequence.loops.append(loop);
	sequence.looping = true;

func ignore_on_success() -> bool:
	return true;
