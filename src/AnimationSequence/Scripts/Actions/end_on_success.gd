extends AnimationSequenceAction

class_name ASAEndOnSuccess

func execute(sequence : AnimationSequence):
	sequence.on_success = false;

func ignore_on_success() -> bool:
	return true;
