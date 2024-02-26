extends Resource
class_name EffectSetChance

## Value that indicates the chance of this effect set activating
@export_range(0, 1) var chance : float = 0;
@export var effect_set : Array[EffectChance];


func get_effect() -> Effect:
	var random = randf();
	var current : float = 0;
	
	for effect in effect_set:
		current += effect.chance;
		
		if random <= current:
			return effect.effect;
	
	return null;
