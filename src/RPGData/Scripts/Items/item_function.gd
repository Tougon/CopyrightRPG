extends Resource
class_name ItemFunction

enum Target { USER, TARGET }
enum CheckMode { EQUALS, GREATER, LESS, GREATEREQUAL, LESSEQUAL }

# Skeleton function used to run an arbitrary event function in the overworld
func execute_overworld(index : int, item : Item = null, preview : bool = false, result : ItemResult = null):
	pass;

# Skeleton function used to run an arbitrary event function in battle
# This will be called from an animation function
func execute_battle(user : EntityController, target : EntityController, item : Item = null):
	pass;
