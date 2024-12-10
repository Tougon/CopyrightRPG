extends EntityController
class_name EnemyController

@export var seal_effect : SealEffectGroup;

# Called when the node enters the scene tree for the first time.
func entity_init(params : BattleParams):
	if params != null:
		# If enemy is out of bounds or null, do not use this enemy
		if get_index() >= params.enemies.size() || params.enemies[get_index()] == null: 
			visible = false;
			return;
		else : 
			visible = true;
			current_entity = params.enemies[get_index()];
	
	if current_entity != null:
		var level_relative = current_entity.level_curve.sample(randf());
		level = lerp(current_entity.min_level, current_entity.max_level, level_relative);
	
	super.entity_init(params)
	await get_tree().process_frame;
	EventManager.register_enemy.emit(self);


func set_enemy_position(pos : Vector2, time : float = 0.0):
	var tween = get_tree().create_tween();
	tween.tween_property(self, "position", pos, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_defeat_complete():
	super._on_defeat_complete();
	
	EventManager.on_enemy_defeated.emit(self);
	#sprite.visible = false;
