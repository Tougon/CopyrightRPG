extends AnimationSequenceAction

class_name ASATerminateAnimation

func execute(sequence : AnimationSequence):
	sequence.running = false;
