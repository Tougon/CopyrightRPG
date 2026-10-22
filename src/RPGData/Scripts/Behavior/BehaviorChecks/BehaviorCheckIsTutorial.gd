extends BehaviorCheck

class_name BehaviorCheckIsTutorial

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	if negate : 
		return !BattleScene.Instance.is_tutorial_battle
	
	return BattleScene.Instance.is_tutorial_battle;
