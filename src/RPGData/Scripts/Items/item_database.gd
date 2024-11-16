extends Resource
class_name ItemDatabase

# Database representing a list of every item in the game
@export var entries: Array[ItemDatabaseEntry];

func get_item(id : int) -> Item:
	if id >= 0 && id < entries.size():
		return entries[id].item;
	
	print("No item with ID " + str(id) + " exists.")
	return null;


func get_id(item : Item) -> int:
	for i in entries.size():
		if entries[i] == item : return i;
	
	print("Item does not exist in the database.")
	return -1;
