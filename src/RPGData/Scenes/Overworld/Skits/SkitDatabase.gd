extends Resource
class_name SkitDatabase

@export var skits : Array[Skit];


func get_skit_from_name (name : String) -> Skit :
	for skit in skits :
		if skit.skit_name == name :
			return skit;
	
	return null;
