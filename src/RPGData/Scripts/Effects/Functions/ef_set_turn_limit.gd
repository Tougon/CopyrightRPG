extends EffectFunction
class_name EFSetTurnLimit

@export var min_turns : int = 3;
@export var max_turns : int = 5;

func execute(instance : EffectInstance):
	instance.turn_limit = randi_range(min_turns, max_turns);
