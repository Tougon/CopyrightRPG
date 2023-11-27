extends Node

signal on_sequence_queue(sequence);
signal on_sequence_queue_empty();

signal on_dialogue_queue(dialogue : String);
signal on_message_queue(message : String);

signal on_battle_begin();

signal register_player(entity : EntityController);
signal register_enemy(entity : EntityController);

# Leaving this intact but given the dictionary might as well not exist, I'm not sure we need.
func _ready():
	pass
