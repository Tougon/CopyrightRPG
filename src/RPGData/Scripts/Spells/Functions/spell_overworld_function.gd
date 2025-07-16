extends Resource
class_name SpellOverworldFunction

enum Target { USER, TARGET }
enum CheckMode { EQUALS, GREATER, LESS, GREATEREQUAL, LESSEQUAL }

# Skeleton function used to run an arbitrary function
func execute(user : int, target : int, spell : Spell) -> bool:
	return false;
