extends AnimationSequenceAction

class_name ASAModifyBackground

@export var pause : bool = false;
# Frame speed modify?


func execute(sequence : AnimationSequence):
	EventManager.modify_bg.emit(pause);
