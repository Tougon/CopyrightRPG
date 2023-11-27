extends Node2D

@export var fade_sequence : TweenPlayer;
@export var sequencer : Sequencer;

var players : Array[EntityController];
var enemies : Array[EntityController];


func _ready():
	EventManager.register_player.connect(_on_player_register);
	EventManager.register_enemy.connect(_on_enemy_register);
	_begin_battle();


func _begin_battle():
	
	await get_tree().process_frame;
	
	# Fade in
	if fade_sequence != null:
		fade_sequence.play_tween_name("Fade In");
		await fade_sequence.tween_ended;
	
	# Print the opening dialogue
	EventManager.on_dialogue_queue.emit(_get_intro_dialogue());
	await EventManager.on_sequence_queue_empty;
	print("Working");


func _on_player_register(entity : EntityController):
	print("Obtain");
	players.append(entity);


func _on_enemy_register(entity : EntityController):
	print("Refrain");
	enemies.append(entity);


func _format_dialogue(dialogue : String, name : String, entity : Entity) -> String:
	# TODO: Add pronoun support
	var entity_name = tr(entity.name_key)
	return dialogue.format({article_indef = GrammarManager.get_indirect_article(name), article_def = GrammarManager.get_direct_article(name), entity = name});


# Helper functions for intro dialogue
func _get_intro_dialogue() -> String:
	if enemies.size() == 0 :
		return "";
	
	var entity = enemies[0].current_entity;
	var name = enemies[0].param.entity_name;
	var key = entity.battle_intro_key;
	
	if enemies.size() > 1:
		if _all_enemies_same():
			key += "_PLURAL";
			name = enemies[0].param.entity_name_plural;
		else:
			key += "_GROUP";
	else:
		key += "_SINGLE";
	
	return _format_dialogue(tr(key), name, entity);


func _all_enemies_same() -> bool:
	if enemies.size() == 0 :
		return true;
	
	var entity = enemies[0].current_entity;
	for enemy in enemies:
		if enemy.current_entity != entity:
			return false;
	return true;
