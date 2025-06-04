extends AnimationSequenceAction

class_name ASABeginOnSuccess

@export var check_hit_instead : bool;

func execute(sequence : AnimationSequence):
	if check_hit_instead : 
		sequence.check_miss = true;
	else : 
		sequence.on_success = true;

func ignore_on_success() -> bool:
	return true;
