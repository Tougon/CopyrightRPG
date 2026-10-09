extends EffectFunction
class_name EFCheckCanAddEntities

enum CheckTarget {Self, Allies, Targets}

func execute(instance : EffectInstance):
	var odds = BattleScene.Instance.times_spawned_extra * BattleManager.DUPLICATION_FAILURE_RATE;
	
	var rand = randf();
	instance.cast_success = rand <= (1.0 - odds);
