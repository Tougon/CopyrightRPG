extends Object
class_name PartyMemberData

var id : int;
var level : int;
var exp : int;
var unlocked : bool;
var hp_dmg : int;
var mp_dmg : int;

# TODO: Add data for equipment and moveset.
var move_list : Array;


func _get_property_list() -> Array:
	var ret: Array = []
	
	ret.append({
		"name": "ID",
		"type": TYPE_INT,
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
	ret.append({
		"name": "Unlocked",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_STORAGE
	})
	ret.append({
		"name": "HP",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	ret.append({
		"name": "MP",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	ret.append({
		"name": "Movelist",
		"type": TYPE_ARRAY,
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
		"Unlocked":
			return unlocked;
		"HP":
			return hp_dmg;
		"MP":
			return mp_dmg;
		"Movelist":
			return move_list;


func _set(property, val) -> bool:
	var retval: bool = true;
	
	match property:
		"ID":
			id = val;
		"Level":
			level = val;
		"Exp":
			exp = val;
		"Unlocked":
			unlocked = val;
		"HP":
			hp_dmg = val;
		"MP":
			mp_dmg = val;
		"Movelist":
			move_list = val;
	
	notify_property_list_changed();
	return retval;
