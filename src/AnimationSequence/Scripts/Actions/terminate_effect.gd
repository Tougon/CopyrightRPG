extends AnimationSequenceAction

class_name ASATerminateEffect

@export var effect_id : int;

func execute(sequence : AnimationSequence):
	var id = clamp(effect_id, 0, sequence.effects.size() - 1);
	
	if id >= 0:
		sequence.effects[id].queue_free();
		sequence.effects.remove_at(id);
	
