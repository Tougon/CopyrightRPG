extends Object
class_name Preferences

var bgm_volume : float = 1;
var sfx_volume : float = 1;


func _get_property_list() -> Array:
	var ret: Array = []
	
	ret.append({
		"name": "BGM Volume",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	ret.append({
		"name": "SFX Volume",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	return ret;


func _get(property):
	
	match property:
		"BGM Volume":
			return bgm_volume;
	
	match property:
		"SFX Volume":
			return sfx_volume;


func _set(property, val) -> bool:
	var retval: bool = true;
	
	match property:
		"BGM Volume":
			bgm_volume = val;
			notify_property_list_changed();
		"SFX Volume":
			sfx_volume = val;
			notify_property_list_changed();
	
	return retval;
