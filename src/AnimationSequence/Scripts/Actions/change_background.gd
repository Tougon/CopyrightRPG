extends AnimationSequenceAction

class_name ASAChangeBackground

enum BGChangeMode { BOTH, VIDEO_ONLY, MATERIAL_ONLY }

@export var reset_bg : bool = false;
@export var index : int = 0;
@export var mode : BGChangeMode = BGChangeMode.BOTH;

func execute(sequence : AnimationSequence):
	var spell = sequence.spell_data;
	
	if reset_bg : EventManager.set_spell_bg.emit(null, index, true, true);
	else : 
		match mode:
			BGChangeMode.BOTH :
				EventManager.set_spell_bg.emit(spell, index, true, true);
			BGChangeMode.VIDEO_ONLY :
				EventManager.set_spell_bg.emit(spell, index, true, false);
			BGChangeMode.MATERIAL_ONLY :
				EventManager.set_spell_bg.emit(spell, index, false, true);
