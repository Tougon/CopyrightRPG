extends AnimationSequenceAction

class_name ASAChangeBackground

@export var reset_bg : bool = false;

func execute(sequence : AnimationSequence):
	var spell = sequence.spell_data;
	
	if reset_bg : EventManager.set_spell_bg.emit(null);
	else : EventManager.set_spell_bg.emit(spell);
