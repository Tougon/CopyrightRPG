extends Resource

class_name AnimationSequenceAction

enum Target { USER, TARGET, EFFECT }


func warmup():
	pass;


func execute(sequence : AnimationSequence):
	pass;


func ignore_on_success() -> bool:
	return false;


func cooldown():
	pass;
