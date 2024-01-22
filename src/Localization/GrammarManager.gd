extends Node


func _ready():
	pass # Replace with function body.


func get_indirect_article(name : String) -> String:
	name = name.to_lower();
	match str(TranslationServer.get_locale()):
		"en_US":
			if name.begins_with("a") || name.begins_with("e") || name.begins_with("i") || name.begins_with("o") || name.begins_with("u"):
				return "An ";
			else:
				return "A ";
	return "";


func get_direct_article(name : String) -> String:
	name = name.to_lower();
	match str(TranslationServer.get_locale()):
		"en_US":
			return "The ";
	return "";
