extends AnimationSequenceAction

class_name ASAPlaySFX

@export var sfx_key : String;

func execute(sequence : AnimationSequence):
	EventManager.play_sfx.emit(sfx_key);
