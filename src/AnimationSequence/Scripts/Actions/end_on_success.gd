extends AnimationSequenceAction

class_name ASAEndOnSuccess

@export var check_hit_instead : bool;

func execute(sequence : AnimationSequence):
	if check_hit_instead : 
		sequence.check_miss = false;
	else : 
		sequence.on_success = false;

func ignore_on_success() -> bool:
	return true;
