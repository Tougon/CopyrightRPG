extends EntityController
class_name EnemyController


# Called when the node enters the scene tree for the first time.
func entity_init():
	super.entity_init()
	await get_tree().process_frame;
	EventManager.register_enemy.emit(self);
