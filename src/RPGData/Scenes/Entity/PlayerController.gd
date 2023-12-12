extends EntityController
class_name PlayerController

@export var attack_action : Spell;
@export var defend_action : Spell;


# Called when the node enters the scene tree for the first time.
func entity_init():
	
	# TODO: Fetch levels and anything else from player data
	
	super.entity_init()
	await get_tree().process_frame;
	EventManager.register_player.emit(self);
