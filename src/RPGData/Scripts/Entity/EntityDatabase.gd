extends Resource
class_name EntityDatabase

# Database representing a list of every entity in the game
@export var entries: Array[EntityDatabaseEntry];


func initialize():
	for entry_id in entries.size() :
		var entry = entries[entry_id];
		
		if entry.entity_path != null :
			if ResourceLoader.exists(entry.entity_path, "Entity"):
				entry.entity = ResourceLoader.load(entry.entity_path, "Entity") as Entity;
			else:
				print("WARNING: Entity path at index " + str(entry_id) + " is invalid!");


func get_entity(id : int, playable : bool = false) -> Entity:
	var last_playable : Entity;
	
	for i in entries.size():
		var entry = entries[i];
		
		if entry.playable && playable : last_playable = entry.entity;
		
		if i == id:
			if playable:
				if !entry.playable: print("Target entity is not marked playable")
				else : return entry.entity;
			else : return entry.entity;
	
	if playable && last_playable != null:
			print("No playable entity with ID " + str(id) + " exists. Returning last available playable.")
			return last_playable;
	
	print("No playable entity with ID " + str(id) + " exists.")
	return null;


func get_id(entity : Entity) -> int:
	for i in entries.size():
		if entries[i].entity == entity : return i;
	
	print("Entity does not exist in the database.")
	return -1;
