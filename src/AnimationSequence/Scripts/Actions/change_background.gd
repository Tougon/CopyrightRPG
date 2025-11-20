extends AnimationSequenceAction

class_name ASAChangeBackground

enum BGChangeMode { BOTH, VIDEO_ONLY, MATERIAL_ONLY }

@export var reset_bg : bool = false;
@export var index : int = 0;
@export var mode : BGChangeMode = BGChangeMode.BOTH;
@export var use_palette : bool = false;
@export var palette_fade_time : float = 1.0;
@export var remain_on_base : bool = false;

func execute(sequence : AnimationSequence):
	var spell = sequence.spell_data;
	
	if reset_bg : 
		EventManager.set_spell_bg.emit(null, index, true, true, true, 0.0, false);
	
	else : 
		match mode:
			BGChangeMode.BOTH :
				EventManager.set_spell_bg.emit(spell, index, true, true, !use_palette, palette_fade_time, false);
			BGChangeMode.VIDEO_ONLY :
				EventManager.set_spell_bg.emit(spell, index, true, false, true, 0.0, false);
			BGChangeMode.MATERIAL_ONLY :
				EventManager.set_spell_bg.emit(spell, index, false, true, !use_palette, palette_fade_time, remain_on_base);
