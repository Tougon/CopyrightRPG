@tool
extends Resource
class_name ItemDatabase

# Database representing a list of every item in the game
@export var entries: Array[ItemDatabaseEntry] :
	set(value):
		var should_rebake = false;
		var loading = false;
		
		# If the size is 0, assume
		if entries != null :
			loading = entries.size() == 0 && value != null && value.size() > 0;
			
			if !loading :
				# If any new entries have been added, set their IDs
				for i in entries.size():
					if value != null && i < value.size():
						if entries[i] == null && value[i] != null:
							should_rebake = true;
		
		entries = value;
		
		if Engine.is_editor_hint() :
			if should_rebake : 
				_rebake_ids();

func initialize():
	for item_id in entries.size() :
		var entry = entries[item_id];
		
		if entry.item_path != null :
			if ResourceLoader.exists(entry.item_path):
				entry.item = ResourceLoader.load(entry.item_path);
			else:
				print("WARNING: Item path at index " + str(item_id) + " is invalid!");


func get_item(id : int) -> Item:
	for entry in entries:
		if entry.id == id : return entry.item;
	
	# -1 is treated as a catch all for an invalid ID throughout the code
	# No item will ever exist at this index, so we can ignore it.
	if id >= 0:
		print("No item with ID " + str(id) + " exists.")
	return null;


func get_id(item : Item) -> int:
	for entry in entries:
		if entry.item == item : return entry.id;
	
	print("Item does not exist in the database.")
	return -1;


func _rebake_ids():
	for entry in entries :
		if entry != null : 
			if entry.id == -1 : 
				var id = _get_last_unused_id();
				print("Rebaking ID, new ID is: " + str(id));
				entry.allow_id_change = true;
				entry.id = id;


func _get_last_unused_id() -> int:
	var id : int = 0;
	
	while (_does_id_exist(id)):
		id += 1;
	
	return id;


func _does_id_exist(id : int) -> bool:
	for entry in entries :
		if entry != null && entry.id == id :
			return true;
	
	return false;
