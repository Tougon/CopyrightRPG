extends Resource
class_name AudioGroup

# Database representing a list of every item in the game
@export var entries : Array[AudioGroupEntry];


func load_group() -> Dictionary:
	var result : Dictionary = {};
	
	for i in entries.size() :
		var entry = entries[i];
		
		var audio = ResourceLoader.load(entry.item_path, "AudioStream")
		if audio == null :
			print("WARNING: Path for " + entry.item_id + " is invalid!");
		else :
			if result.has(entry.item_id) :
				print("WARNING: " + entry.item_id + " is duplicated!");
			else : 
				result[entry.item_id] = audio;
	
	return result;


func load_id(id : String) -> AudioStream:
	for i in entries.size() :
		var entry = entries[i];
		
		if entry.item_id != id : continue;
		
		var audio = ResourceLoader.load(entry.item_path, "AudioStream")
		if audio == null :
			print("WARNING: Path for " + entry.item_id + " is invalid!");
		else :
			return audio;
	
	return null;
