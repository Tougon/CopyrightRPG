extends EffectFunction
class_name EFCheckRandom

@export_range(0, 1) var chance : float = 0.5;

func execute(instance : EffectInstance):
	var rand = randf();
	instance.cast_success = rand <= chance;
