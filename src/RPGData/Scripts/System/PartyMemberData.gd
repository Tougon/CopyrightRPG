extends Object
class_name PartyMemberData

var id : String;
var level : int;
var exp : int;

# TODO: Add data for equipment and moveset.


func _get_property_list() -> Array:
	var ret: Array = []
	
	ret.append({
		"name": "ID",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_STORAGE
	})
	ret.append({
		"name": "Level",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	ret.append({
		"name": "Exp",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	return ret;


func _get(property):
	
	match property:
		"ID":
			return id;
		"Level":
			return level;
		"Exp":
			return exp;


func _set(property, val) -> bool:
	var retval: bool = true;
	
	match property:
		"ID":
			id = val;
		"Level":
			level = val;
		"Exp":
			exp = val;
	
	notify_property_list_changed();
	return retval;
