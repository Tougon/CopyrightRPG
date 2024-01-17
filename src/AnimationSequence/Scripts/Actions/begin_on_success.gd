extends AnimationSequenceAction

class_name ASABeginOnSuccess

func execute(sequence : AnimationSequence):
	sequence.on_success = true;

func ignore_on_success() -> bool:
	return true;
