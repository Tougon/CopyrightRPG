extends BehaviorCheck

class_name BehaviorCheckSealTarget


func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	result.check_target = check_target;
	if check_target == CheckTarget.Self:
		return !negate;
	else:
		var check_ec = targets;
		
		if check_target == CheckTarget.Allies:
			check_ec = allies;
		
		var value = -1.0;
		var entities : Array[EntityController];
		
		var seals = BattleScene.Instance.seal_manager.seal_instances;
		
		for seal in seals :
			if seal.seal_entity != user && check_ec.has(seal.seal_entity):
				entities.append(seal.seal_entity);
		
		if entities.size() > 0 :
			result.trigger_entity = entities.pick_random();
			return true;
		
	return false;
