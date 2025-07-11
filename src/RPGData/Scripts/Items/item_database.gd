extends Resource
class_name ItemDatabase

# Database representing a list of every item in the game
@export var entries: Array[ItemDatabaseEntry];


func initialize():
	for item_id in entries.size() :
		var entry = entries[item_id];
		
		if entry.item_path != null :
			if ResourceLoader.exists(entry.item_path):
				entry.item = ResourceLoader.load(entry.item_path);
			else:
				print("WARNING: Item path at index " + str(item_id) + " is invalid!");


func get_item(id : int) -> Item:
	if id >= 0 && id < entries.size():
		return entries[id].item;
	
	# -1 is treated as a catch all for an invalid ID throughout the code
	# No item will ever exist at this index, so we can ignore it.
	if id >= 0:
		print("No item with ID " + str(id) + " exists.")
	return null;


func get_id(item : Item) -> int:
	for i in entries.size():
		if entries[i].item == item : return i;
	
	print("Item does not exist in the database.")
	return -1;
