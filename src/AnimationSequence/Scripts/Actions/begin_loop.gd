extends AnimationSequenceAction

class_name ASABeginLoop

@export var num_loops : int;
@export var loop_targets : bool;

func execute(sequence : AnimationSequence):
	var loops = num_loops;
	
	if loop_targets : 
		loops = sequence.loop_targets;
	elif loops < 0 :
		loops = sequence.loop_hits;
	
	var loop = AnimationSequenceLoop.new(sequence.current_frame, sequence.current_action_index, loops);
	sequence.loops.append(loop);
	sequence.looping = true;

func ignore_on_success() -> bool:
	return true;
