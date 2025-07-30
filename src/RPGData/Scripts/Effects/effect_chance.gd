extends Resource
class_name EffectChance

## Value that indicates the chance of this effect activating
@export_range(0, 1) var chance : float = 0;
@export var effect : Effect;
@export var use_luck : bool = false;
