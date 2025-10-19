extends EntityController
class_name EnemyController

var seal_effect : SealEffectGroup;
var seal_effect_list : Array[SealEffectGroup];
@export var enemy_index : int;

# Called when the node enters the scene tree for the first time.
func entity_init(params : BattleParams):
	if current_entity == null && params != null:
		# If enemy is out of bounds or null, do not use this enemy
		if enemy_index >= params.enemies.size() || params.enemies[enemy_index] == null: 
			visible = false;
		else : 
			visible = true;
			current_entity = params.enemies[enemy_index];
	
	if current_entity != null:
		var level_relative = current_entity.level_curve.sample(randf());
		level = lerp(current_entity.min_level, current_entity.max_level, level_relative);
		
		seal_effect_list = current_entity.seal_effect_list;
	
	super.entity_init(params)
	await get_tree().process_frame;
	
	if params != null :
		EventManager.register_enemy.emit(self);


func set_enemy_position(pos : Vector2, time : float = 0.0):
	if time <= 0.0 :
		position = pos;
	else :
		var tween = get_tree().create_tween();
		tween.tween_property(self, "position", pos, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _set_seal_id(id : int):
	if id >= 0 && id < seal_effect_list.size():
		seal_effect = seal_effect_list[id];
	else :
		seal_effect = seal_effect_list.pick_random();


func _on_defeat_complete():
	super._on_defeat_complete();
	
	EventManager.on_enemy_defeated.emit(self);
	#sprite.visible = false;
