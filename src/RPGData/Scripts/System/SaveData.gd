extends Object
class_name SaveData

var player_position : Vector2;
var inventory : Dictionary;


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
	
	return ret;


func _get(property):
	
	match property:
		"Player Position":
			return player_position;
	
	match property:
		"Inventory":
			return inventory;


func _set(property, val) -> bool:
	var retval: bool = true;
	
	match property:
		"Player Position":
			player_position = val;
			notify_property_list_changed();
		"Inventory":
			inventory = val;
			notify_property_list_changed();
	
	return retval;
