extends Resource

class_name FieldEffectFunction
enum Side { BOTH, PLAYER, ENEMY }
enum Stat { ATTACK, DEFENSE, SPATTACK, SPDEFENSE, SPEED, ACCURACY, EVASION, HIGHEST, LOWEST, CACHE }

# Skeleton function used to run an arbitrary event function
func execute(field_effect : FieldEffect, players : Array[EntityController], enemies : Array[EntityController]):
	pass;
