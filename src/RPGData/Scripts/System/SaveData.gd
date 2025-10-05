extends Object
class_name SaveData

var player_position : Vector2;
var player_scene : String;
var player_area : String;
var player_floor : int;
var player_floor_change : bool;
var inventory : Dictionary;

var flee_group_chance : float;
var flee_group : Array;


func _get_property_list() -> Array:
	var ret: Array = []
	
	ret.append({
		"name": "Player Position",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	ret.append({
		"name": "Inventory",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	ret.append({
		"name": "Player Scene",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	ret.append({
		"name": "Player Area",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	ret.append({
		"name": "Player Floor",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	ret.append({
		"name": "Player Floor Change",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	ret.append({
		"name": "Flee Group Chance",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	ret.append({
		"name": "Flee Group",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	return ret;


func _get(property):
	
	match property:
		"Player Position":
			return player_position;
		"Player Scene":
			return player_scene;
		"Player Area":
			return player_area;
		"Player Floor":
			return player_floor;
		"Player Floor Change":
			return player_floor_change;
		"Flee Group Chance":
			return flee_group_chance;
		"Flee Group":
			return flee_group;
		"Inventory":
			return inventory;


func _set(property, val) -> bool:
	var retval: bool = true;
	
	match property:
		"Player Position":
			player_position = val;
			notify_property_list_changed();
		"Player Scene":
			player_scene = val;
			notify_property_list_changed();
		"Player Area":
			player_area = val;
			notify_property_list_changed();
		"Player Floor":
			player_floor = val;
			notify_property_list_changed();
		"Player Floor Change":
			player_floor_change = val;
			notify_property_list_changed();
		"Flee Group Chance":
			flee_group_chance = val;
			notify_property_list_changed();
		"Flee Group":
			flee_group = val;
			notify_property_list_changed();
		"Inventory":
			inventory = val;
			notify_property_list_changed();
	
	return retval;
