extends MenuPanel

var current_entity : EntityController;


# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.set_active_player.connect(_set_active_entity);
	super._ready();


func on_tween_end_active(tween_name : String):
	super.on_tween_end_active(tween_name);
	
	# TODOGAME: Re-evaluate?
	#var msg = tr("T_BATTLE_TURN_READY").format({entity = current_entity.param.entity_name});
	#EventManager.on_message_queue.emit(msg);


func _set_active_entity(entity : EntityController):
	current_entity = entity;


func on_focus():
	# TODOGAME: As we add more options to the menu, this must be expanded.
	if current_entity != null && (current_entity is PlayerController):
		match (current_entity.prev_action_type):
			PlayerController.ActionType.ATTACK:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Attack";
			PlayerController.ActionType.DEFEND:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Defend";
			PlayerController.ActionType.SPELL:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Magic";
				
	else:
		initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Attack";


func _on_attack_button_pressed():
	EventManager.on_attack_select.emit();


func _on_defend_button_pressed():
	EventManager.on_defend_select.emit();


func _on_magic_button_pressed():
	EventManager.on_magic_select.emit();


func on_menu_cancel():
	EventManager.player_menu_cancel.emit();

func _on_destroy():
	super._on_destroy();
	if EventManager != null:
		EventManager.set_active_player.disconnect(_set_active_entity);
