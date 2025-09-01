extends Node

# Loading Events
signal load_scene(path : String);

# Sequencing Events
signal on_sequence_queue(sequence);
signal on_sequence_queue_first(sequence);
signal on_sequence_queue_empty();

# Audio Events
signal play_bgm(id : String, fade_time : float, crossfade : bool, start_time : float, start_volume : float);
signal fade_bgm(volume : float, fade_time : float, stop : bool);
signal play_sfx(id : String);
signal load_aux_audio(group : AudioGroup);
signal unload_aux_audio();

signal change_bgm_volume_preference(amount : float);
signal change_sfx_volume_preference(amount : float);

# Dialogue Events
signal on_dialogue_queue(dialogue : String);
signal on_message_queue(message : String);

# Global Overworld Events
signal on_overworld_player_moved(direction : Vector2, amount : Vector2, delta : float);
signal on_overworld_change_area(new_area : String);
signal on_overworld_change_floor(new_floor : int, teleport : bool, pos : Vector2);
signal on_player_enter_floor_change_zone(enter : bool);

signal on_battle_queue(encounter : Encounter);
signal on_battle_dequeue();

signal set_player_can_move(can_move : bool);

signal overworld_cutscene_fade_instant(fade_in : bool);
signal overworld_cutscene_fade_start(fade_in : bool);
signal overworld_cutscene_fade_completed(fade_in : bool);

signal overworld_battle_fade_start(fade_in : bool);
signal overworld_battle_fade_completed(fade_in : bool);

signal overworld_transition_fade_start(fade_in : bool);
signal overworld_transition_fade_completed(fade_in : bool);

# Overworld UI Events
signal on_player_equipment_selected(equipment_type : EquipmentItem.EquipmentType, player_data : PartyMemberData, entity : Entity)
signal on_player_move_selected(move_index : int, player_data : PartyMemberData, entity : Entity)
signal on_player_spell_attempt_use(user : int, spell : Spell);
signal on_inventory_item_selected(item : Item);
signal refresh_current_inventory_item();
signal refresh_player_info();
signal refresh_player_move_list(move_list : Array);
signal on_equipment_item_highlighted(equipment : EquipmentItem, equipment_type : EquipmentItem.EquipmentType);
signal refresh_player_equipment(equipment_type : EquipmentItem.EquipmentType, item_id : int);

# Global Battle Events
signal on_battle_begin(params : BattleParams);
signal on_turn_begin();
signal set_player_group_state(active : bool);

signal register_player(entity : EntityController);
signal register_enemy(entity : EntityController);

signal set_player_ready();
signal set_active_player(entity : EntityController);
signal set_player_bg(entity : EntityController);
signal set_spell_bg(spell : Spell, index : int, change_video : bool, change_material : bool, use_entity_palette : bool, palette_transition_duration : float);
signal set_effect_bg(layer : int, spell : Spell, index : int, change_video : bool, change_material : bool, use_entity_palette : bool, palette_transition_duration : float, set_transparent : bool);
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
signal on_entity_turn_end(entity : EntityController);

signal on_entity_defeated(entity : EntityController);
signal on_enemy_defeated(entity : EntityController);
signal on_player_take_damage(defeated : bool, crit : bool, block : bool);
signal on_player_defeated(entity : EntityController);
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
