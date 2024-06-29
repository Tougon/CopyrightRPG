extends EntityController
class_name EnemyController

@export var seal_effect : Effect;

# Called when the node enters the scene tree for the first time.
func entity_init():
	# TODO: Randomize level based on the applicable range
	if current_entity != null:
		var level_relative = current_entity.level_curve.sample(randf());
		level = lerp(current_entity.min_level, current_entity.max_level, level_relative);
	
	super.entity_init()
	await get_tree().process_frame;
	EventManager.register_enemy.emit(self);


func _on_defeat_complete():
	super._on_defeat_complete();
	
	EventManager.on_enemy_defeated.emit(self);
	#sprite.visible = false;
