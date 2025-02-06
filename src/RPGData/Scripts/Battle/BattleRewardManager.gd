extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.on_battle_completed.connect(_on_battle_complete);


func _on_battle_complete(result : BattleResult):
	if result != null && result.victory:
		# Results Music
		EventManager.play_bgm.emit("battle_win", 0.2, true, 0, 1);
		
		if result.exp > 0:
			var exp : String;
			
			exp = tr("T_BATTLE_RESULT_VICTORY_EXP")
			
			exp = exp.format({amount = result.exp});
			EventManager.on_dialogue_queue.emit(exp);
			
			for player in result.players:
				if player.should_award_exp:
					var level = player.override_level;
					
					var award_exp = result.exp;
					var current_exp = DataManager.party_data[player.id].exp;
					var next_level_amt = player.override_entity.get_level_exp(level);
					
					while award_exp + current_exp >= next_level_amt && player.override_level < BattleManager.level_cap:
						# TODO: Level up screen/animation
						#EventManager.on_dialogue_queue.emit("LEVEL UP!");
						level += 1;
						award_exp -= (next_level_amt - current_exp);
						current_exp = 0;
						next_level_amt = player.override_entity.get_level_exp(level);
					
					player.override_level = level;
					player.modified_exp_amt = award_exp;
	else:
		# Defeat Music
		EventManager.play_bgm.emit("battle_lose", 0.2, true, 0, 1);
		
		EventManager.on_dialogue_queue.emit(tr("T_BATTLE_RESULT_DEFEAT"));
	
	await EventManager.on_sequence_queue_empty;
	
	# Fade Out
	EventManager.set_player_group_state.emit(false);
	await get_tree().create_timer(0.1).timeout
	
	EventManager.fade_bgm.emit(0.0, 0.0, true);
	EventManager.battle_fade_start.emit(false);
	await EventManager.battle_fade_completed;
	
	# Scene removal code.
	EventManager.on_battle_end.emit(result);


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_completed.disconnect(_on_battle_complete);
