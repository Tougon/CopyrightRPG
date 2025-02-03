extends Resource
class_name ItemDatabase

# Database representing a list of every item in the game
@export var entries: Array[ItemDatabaseEntry];


func initialize():
	for item_id in entries.size() :
		var entry = entries[item_id];
		
		if entry.item_path != null :
			if ResourceLoader.exists(entry.item_path, "Item"):
				entry.item = ResourceLoader.load(entry.item_path, "Item") as Item;
			else:
				print("WARNING: Item path at index " + str(item_id) + " is invalid!");


func get_item(id : int) -> Item:
	if id >= 0 && id < entries.size():
		return entries[id].item;
	
	print("No item with ID " + str(id) + " exists.")
	return null;


func get_id(item : Item) -> int:
	for i in entries.size():
		if entries[i].item == item : return i;
	
	print("Item does not exist in the database.")
	return -1;
