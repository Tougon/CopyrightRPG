extends Resource

class_name EffectFunction
enum Target { USER, TARGET }
enum CheckMode { EQUALS, GREATER, LESS, GREATEREQUAL, LESSEQUAL }
enum Stat { ATTACK, DEFENSE, SPATTACK, SPDEFENSE, SPEED, ACCURACY, EVASION, HIGHEST, LOWEST, CACHE, RANDOM, BESTOFFENSE }

# Skeleton function used to run an arbitrary event function
func execute(instance : EffectInstance):
	pass;
