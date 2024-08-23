@tool
extends Resource

class_name EntityStatFloat

@export var min : float : 
	set(new_min):
		if new_min < 0:
			min = 0;
		else:
			min = new_min;

@export var max : float : 
	set(new_max):
		if new_max < 0:
			max = 0;
		elif new_max < min:
			pass;
		else:
			max = new_max;

@export var growth : Curve;

func get_current(level : int) -> float:
	# Level 1 is the minimum so it needs to be counted as 0
	level -= 1;
	
	if level > BattleManager.level_cap: level = BattleManager.level_cap;
	if level < 0 : level = 0;
	
	var percent = (level as float) / (BattleManager.level_cap as float);
	return (lerp(min, max, growth.sample(percent)));
