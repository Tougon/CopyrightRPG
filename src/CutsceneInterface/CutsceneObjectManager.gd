extends Node

var _object_list := {};

func _ready() -> void:
	pass


func add_object(object : CutsceneObject):
	# Ignore this object if it has a null id or no id. It will not be used.
	if object.object_id == null || object.object_id == "" : return;
	
	if _object_list.has(object.object_id):
		print("ERROR: Object ID " + object.object_id + " is not unique.");
		return;
	
	_object_list[object.object_id] = object;


func get_object(id : String) -> CutsceneObject :
	if id.is_empty() : return;
	
	if !_object_list.has(id):
		print("ERROR: Object ID " + id + " does not exist.");
		return null;
	
	return _object_list[id];


func remove_object(object : CutsceneObject):
	# Ignore this object if it has a null id or no id. It will not be used.
	if object.object_id == null || object.object_id == "" : return;
	
	if _object_list.has(object.object_id):
		_object_list.erase(object.object_id);
		return;
