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
		elif new_max < min:
			pass;
		else:
			max = new_max;

@export var growth : Curve;

func get_current(level : int, max_level : int) -> int:
	# Level 1 is the minimum so it needs to be counted as 0
	level -= 1;
	# Max needs to be subtracted as well or caps will never be hit
	max_level -= 1;
	
	if max_level > BattleManager.level_cap: max_level = BattleManager.level_cap;
	if max_level == 0 : max_level = 1;
	if level > BattleManager.level_cap: level = BattleManager.level_cap;
	if level < 0 : level = 0;
	
	var percent = (level as float) / (max_level as float);
	return roundi(lerp(min, max, growth.sample(percent)));
