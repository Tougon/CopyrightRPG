extends Node

# Sequencing Events
signal on_sequence_queue(sequence);
signal on_sequence_queue_first(sequence);
signal on_sequence_queue_empty();

# Dialogue Events
signal on_dialogue_queue(dialogue : String);
signal on_message_queue(message : String);

# Global Overworld Events
signal on_overworld_player_moved(direction : Vector2, amount : Vector2, delta : float);
signal on_battle_queue(encounter : Encounter);
signal on_battle_dequeue();

signal overworld_cutscene_fade_initialize(fade_in : bool);
signal overworld_cutscene_fade_start(fade_in : bool);
signal overworld_cutscene_fade_completed(fade_in : bool);

signal overworld_battle_fade_start(fade_in : bool);
signal overworld_battle_fade_completed(fade_in : bool);

# Global Battle Events
signal on_battle_begin(params : BattleParams);
signal on_turn_begin();
signal set_player_group_state(active : bool);

signal register_player(entity : EntityController);
signal register_enemy(entity : EntityController);

signal set_player_ready();
signal set_active_player(entity : EntityController);
signal player_menu_cancel();

signal on_attack_select();
signal on_defend_select();
signal on_magic_select();
signal on_item_select();
signal initialize_target_menu(entity : EntityController);
signal initialize_magic_menu(entity : EntityController);
signal initialize_item_menu(entity : EntityController);
signal on_action_selected(action : Spell, sealing : bool);
signal highlight_target(entity : EntityController, all : bool);
signal click_target(entity : EntityController);

signal on_player_item_consumed(item : Item);
signal on_player_items_changed(items : Dictionary, delta : Item);

signal on_entity_move(entity : EntityController);

signal on_entity_defeated(entity : EntityController);
signal on_enemy_defeated(entity : EntityController);
signal on_player_take_damage(defeated : bool, crit : bool);
signal on_players_defeated();
signal on_battle_completed(result : BattleResult);
signal on_battle_end(result : BattleResult);

# Battle UI Events
signal hide_entity_ui();
signal battle_fade_start(fade_in : bool);
signal battle_fade_completed(fade_in : bool);


# Leaving this intact but given the dictionary might as well not exist, I'm not sure we need.
func _ready():
	pass
