extends AnimationSequenceAction

class_name ASABackgroundEffect

enum BGChangeMode { BOTH, VIDEO_ONLY, MATERIAL_ONLY }

@export var reset_bg : bool = false;
@export var effect_layer : int = 0;
@export var index : int = 0;
@export var mode : BGChangeMode = BGChangeMode.BOTH;
@export var use_palette : bool = true;
@export var palette_fade_time : float = 1.0;
@export var fade_to_transparent : bool = false;

func execute(sequence : AnimationSequence):
	var spell = sequence.spell_data;
	
	print("Effect Stuff");
	if reset_bg : 
		EventManager.set_effect_bg.emit(effect_layer, null, index, true, true, true, 0.0, fade_to_transparent);
	
	else : 
		match mode:
			BGChangeMode.BOTH :
				EventManager.set_effect_bg.emit(effect_layer, spell, index, true, true, !use_palette, palette_fade_time, fade_to_transparent);
			BGChangeMode.VIDEO_ONLY :
				EventManager.set_effect_bg.emit(effect_layer, spell, index, true, false, true, 0.0, fade_to_transparent);
			BGChangeMode.MATERIAL_ONLY :
				EventManager.set_effect_bg.emit(effect_layer, spell, index, false, true, !use_palette, palette_fade_time, fade_to_transparent);
