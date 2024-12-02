extends Resource
class_name RPGCharacterAnimationGroup

@export var north : RPGCharacterAnimation;
@export var east : RPGCharacterAnimation;
@export var south : RPGCharacterAnimation;
@export var west : RPGCharacterAnimation;

func get_anim(direction : Vector2, previous_direction : Vector2) -> RPGCharacterAnimation:
	if direction.length_squared() == 0: return south;
	
	# Check if moving diagonally. We prioritize N/S if player was previously moving N/S
	if direction.y > 0 && abs(direction.y) < 1 :
		# Accounting for rounding errors
		if abs(previous_direction.y) > 0.8:
			if previous_direction.y < 0 : return north;
			else : return south;
		else:
			if previous_direction.x > 0: return east;
			else : return west;
	
	if direction.x > 0 : return east;
	elif direction.x < 0 : return west;
	if direction.y < 0 : return north;
	elif direction.y > 0 : return south;
	
	return south;
