@tool
extends Resource

class_name EntityStat

@export var min : int : 
	set(new_min):
		if new_min < 0:
			min = 0;
		else:
			min = new_min;

@export var max : int : 
	set(new_max):
		if new_max < 0:
			max = 0;
		else:
			max = new_max;

@export var growth : Curve;

func get_current(level : int) -> int:
	if level > BattleManager.level_cap:
		level = BattleManager.level_cap;
	
	var percent = (level as float) / (BattleManager.level_cap as float);
	return roundi(lerp(min, max, growth.sample(percent)));
