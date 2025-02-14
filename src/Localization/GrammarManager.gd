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
				
				if names[i].param.entity_generic :
					result += get_direct_article(name) + name;
				else :
					result += name;
				
				# Add a comma
				if(names.size() > 2 && i < names.size() - 2):
					result += ", ";
				elif (names.size() > 1 && i == names.size() - 2):
					result += "&";
			
			return result;
	return "";


func get_direct_article(name : String, gender : String = "U") -> String:
	name = name.to_lower();
	match str(TranslationServer.get_locale()):
		"en_US":
			return "The ";
	return "";


func get_pronoun(gender : Entity.Gender, type : int) -> String:
	match str(TranslationServer.get_locale()):
		"en_US":
			match gender:
				Entity.Gender.NEUTRAL:
					match type:
						1:
							return "it";
						2:
							return "it";
						3: 
							return "its";
						4:
							return "it's";
				Entity.Gender.MALE:
					match type:
						1:
							return "he";
						2:
							return "him";
						3: 
							return "his";
						4:
							return "he's";
				Entity.Gender.FEMALE:
					match type:
						1:
							return "she";
						2:
							return "her";
						3: 
							return "hers";
						4:
							return "her's";
				Entity.Gender.NONBINARY:
					match type:
						1:
							return "they";
						2:
							return "them";
						3: 
							return "theirs";
						4:
							return "theirs";
				Entity.Gender.PLURAL:
					match type:
						1:
							return "they";
						2:
							return "them";
						3: 
							return "theirs";
						4:
							return "theirs";
	return "";
