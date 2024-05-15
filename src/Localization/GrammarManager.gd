extends Node


func _ready():
	pass # Replace with function body.


func get_indirect_article(name : String, gender : String = "U") -> String:
	name = name.to_lower();
	match str(TranslationServer.get_locale()):
		"en_US":
			if name.begins_with("a") || name.begins_with("e") || name.begins_with("i") || name.begins_with("o") || name.begins_with("u"):
				return "An ";
			else:
				return "A ";
	return "";


func get_plural_string(names : Array[EntityController]) -> String:
	match str(TranslationServer.get_locale()):
		"en_US":
			var result = "";
			
			for i in names.size():
				var name = names[i].param.entity_name;
				result += get_direct_article(name);
				
				# Add a comma
				if(names.size() > 2 && i < names.size() - 2):
					result += ", ";
				elif (names.size() > 1 && i == names.size() - 2):
					result += "&";
	return "";


func get_direct_article(name : String, gender : String = "U") -> String:
	name = name.to_lower();
	match str(TranslationServer.get_locale()):
		"en_US":
			return "The ";
	return "";
