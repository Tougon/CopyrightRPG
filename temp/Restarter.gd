extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.on_battle_completed.connect(_on_battle_complete);


func _on_battle_complete(result : BattleResult):
	if result != null && result.victory:
		if result.exp > 0:
			var exp : String;
			
			# TODO: Check living players in battle result and evaluate
			exp = tr("T_BATTLE_RESULT_VICTORY_EXP")
			
			exp = exp.format({amount = result.exp});
			EventManager.on_dialogue_queue.emit(exp);
	else:
		EventManager.on_dialogue_queue.emit(tr("T_BATTLE_RESULT_DEFEAT"));
	
	await EventManager.on_sequence_queue_empty;
	
	# Fade Out
	EventManager.battle_fade_start.emit(false);
	await EventManager.battle_fade_completed;
	
	# Scene removal code.
	EventManager.on_battle_end.emit(result);


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_completed.disconnect(_on_battle_complete);
