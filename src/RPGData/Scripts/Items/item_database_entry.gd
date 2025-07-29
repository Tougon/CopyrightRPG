@tool
extends Resource
class_name ItemDatabaseEntry

var item : Item;
@export var id : int = -1:
	set(value):
		var can_change = allow_id_change || !Engine.is_editor_hint();
		
		# We need to allow IDs to change if we are loading in editor
		if Engine.is_editor_hint() && (id == -1 && value != -1):
			can_change = true;
		
		if can_change: 
			id = value;
			if allow_id_change : 
				print("Accept Change: " + str(value) + " " + str(id))
			allow_id_change = false;
		else :
			id = id;

var allow_id_change : bool = false;

@export_file("*.tres") var item_path: String;


func set_id(new_id : int):
	allow_id_change = true;
	id = new_id;
