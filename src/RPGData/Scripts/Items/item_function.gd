extends Resource
class_name ItemFunction

enum Target { USER, TARGET }

# Skeleton function used to run an arbitrary event function in the overworld
func execute_overworld(target : int):
	pass;

# Skeleton function used to run an arbitrary event function in battle
# This will be called from an animation function
func execute_battle(user : EntityController, target : EntityController):
	pass;
