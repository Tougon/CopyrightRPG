extends AnimationSequenceAction

class_name ASABeginLoop

@export var num_loops : int;
@export var loop_targets : bool;

func execute(sequence : AnimationSequence):
	var loops = num_loops;
	
	if loop_targets : 
		loops = sequence.target.size();
	elif num_loops < 0 :
		loops = sequence.loop;
	
	var loop = AnimationSequenceLoop.new(sequence.current_frame, loops);
	sequence.loops.append(loop);
	sequence.looping = true;

func ignore_on_success() -> bool:
	return true;
