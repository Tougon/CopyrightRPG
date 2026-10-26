extends Resource
class_name FloorSFXMap

@export var floor_sfx_map : Dictionary;


func get_floor_sfx(floor_id : int) -> String :
	if floor_sfx_map.has(floor_id) :
		return floor_sfx_map[floor_id];
	
	return "";
