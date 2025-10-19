extends BehaviorCheck

class_name BehaviorCheckRandom

@export_range(0, 1) var chance : float = 0.5;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	var random = randf();
	return random <= chance;
