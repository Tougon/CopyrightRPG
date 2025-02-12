extends Node2D

@export var animation : Spell;
@export var dummy_player : Entity
@export var dummy_enemy : Entity
@export var entity_controllers : Array[EntityController];

var player : PlayerController;
var enemies : Array[EntityController];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var fake_battle = BattleParams.new();
	
	var player_data = BattleParamEntity.new();
	player_data.id = 0;
	player_data.override_level = 1;
	player_data.override_entity = dummy_player;
	
	fake_battle.players.append(player_data)
	
	# Add 5 copies of the entity to the fake data
	fake_battle.enemies.append(dummy_enemy);
	fake_battle.enemies.append(dummy_enemy);
	fake_battle.enemies.append(dummy_enemy);
	fake_battle.enemies.append(dummy_enemy);
	fake_battle.enemies.append(dummy_enemy);
	
	for controller in entity_controllers:
		controller.entity_init(fake_battle);
		
		if controller is PlayerController :
			player = controller;
		elif controller is EnemyController :
			enemies.append(controller);
	
	play_animation();


func play_animation():
	player.current_action = animation;
	player.enemies = enemies;
	
	var spell_cast = player.current_action.cast(player, player.enemies);
	# Rig the damage roll to do nothing
	for cast in spell_cast:
		for i in cast.damage.size():
			cast.damage[i] = 0;
		
		cast.total_damage = 0;
		
		for i in cast.hits.size():
			cast.hits[i] = true;
		
	player.action_result = spell_cast;
	
	var animation_seq = AnimationSequence.new(get_tree(), animation.animation_sequence, player, enemies, spell_cast);
	EventManager.on_sequence_queue.emit(animation_seq);
	
	await EventManager.on_sequence_queue_empty;
	await get_tree().create_timer(1.0).timeout
	play_animation();
