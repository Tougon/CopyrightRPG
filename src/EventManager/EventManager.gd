extends Node

# Sequencing Events
signal on_sequence_queue(sequence);
signal on_sequence_queue_first(sequence);
signal on_sequence_queue_empty();

# Dialogue Events
signal on_dialogue_queue(dialogue : String);
signal on_message_queue(message : String);

# Global Battle Events
signal on_battle_begin();
signal on_turn_begin();

signal register_player(entity : EntityController);
signal register_enemy(entity : EntityController);

signal set_player_ready();
signal set_active_player(entity : EntityController);
signal player_menu_cancel();

signal on_attack_select();
signal on_defend_select();
signal on_magic_select();
signal initialize_target_menu(entity : EntityController);
signal initialize_magic_menu(entity : EntityController);
signal on_action_selected(action : Spell, sealing : bool);
signal highlight_target(entity : EntityController, all : bool);
signal click_target(entity : EntityController);

signal hide_entity_ui();

signal on_entity_move(entity : EntityController);

signal on_entity_defeated(entity : EntityController);
signal on_enemy_defeated(entity : EntityController);
signal on_players_defeated();
signal on_battle_completed(victory : bool);


# Leaving this intact but given the dictionary might as well not exist, I'm not sure we need.
func _ready():
	pass
