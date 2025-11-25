extends MenuPanel

@export var atk_display : PlayerStatStageDisplay;
@export var def_display : PlayerStatStageDisplay;
@export var mag_display : PlayerStatStageDisplay;
@export var res_display : PlayerStatStageDisplay;
@export var spd_display : PlayerStatStageDisplay;
@export var acc_display : PlayerStatStageDisplay;
@export var eva_display : PlayerStatStageDisplay;

var current_entity : EntityController;


# Called when the node enters the scene tree for the first time.
func _ready():
	$"Status Area".visible = false;
	super._ready();
	
	for selection in all_selections:
		selection.focus_entered.connect(_on_button_focus);
		if selection is Button :
			(selection as Button).button_down.connect(_on_button_down);
			(selection as Button).pressed.connect(_on_button_up);


func _enter_tree():
	super._enter_tree();
	
	EventManager.set_active_player.connect(_set_active_entity);


func on_tween_end_active(tween_name : String):
	super.on_tween_end_active(tween_name);
	
	# TODO: Re-evaluate?
	#var msg = tr("T_BATTLE_TURN_READY").format({entity = current_entity.param.entity_name});
	#EventManager.on_message_queue.emit(msg);


func _set_active_entity(entity : EntityController, is_first : bool):
	current_entity = entity;
	
	atk_display.set_stat_display_value(current_entity.atk_stage);
	def_display.set_stat_display_value(current_entity.def_stage);
	mag_display.set_stat_display_value(current_entity.sp_atk_stage);
	res_display.set_stat_display_value(current_entity.sp_def_stage);
	spd_display.set_stat_display_value(current_entity.spd_stage);
	acc_display.set_stat_display_value(current_entity.accuracy_stage);
	eva_display.set_stat_display_value(current_entity.evasion_stage);
	
	# Change text on ESC button
	if is_first :
		$"BG Area/Player Options/ScrollContainer/GridContainer/Escape/Label".text = tr("T_BATTLE_MAIN_UI_ESCAPE");
	else :
		$"BG Area/Player Options/ScrollContainer/GridContainer/Escape/Label".text = tr("T_BATTLE_MAIN_UI_BACK");


func on_focus():
	# TODO: As we add more options to the menu, this must be expanded.
	if current_entity != null && (current_entity is PlayerController):
		match (current_entity.prev_action_type):
			PlayerController.ActionType.ATTACK:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Attack";
			PlayerController.ActionType.DEFEND:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Defend";
			PlayerController.ActionType.SPELL:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Skills";
			PlayerController.ActionType.ITEM:
				if current_entity.has_any_items:
					initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Item";
		
	else:
		initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Attack";
	
	$"BG Area/Player Options/ScrollContainer/GridContainer/Item".disabled = !current_entity.has_any_items();
	$"BG Area/Player Options/ScrollContainer".ensure_control_visible(initial_selection);


func _show_hide_status(show : bool):
	var play_audio = show != $"Status Area".visible;
	$"Status Area".visible = show;
	
	if play_audio :
		if show :
			AudioManager.play_sfx("battle_menu_aux", 0.1);
		else :
			AudioManager.play_sfx("battle_menu_cancel", 0.1);


func _on_attack_button_pressed():
	EventManager.on_attack_select.emit();


func _on_defend_button_pressed():
	EventManager.on_defend_select.emit();


func _on_magic_button_pressed():
	EventManager.on_magic_select.emit();


func _on_item_button_pressed():
	EventManager.on_item_select.emit();


func _on_status_button_pressed():
	_show_hide_status(true);


func _on_escape_button_pressed():
	EventManager.player_menu_cancel.emit(false);


func on_menu_cancel():
	if $"Status Area".visible :
		_show_hide_status(false);
		return;
	
	EventManager.player_menu_cancel.emit(true);


func on_unfocus():
	_show_hide_status(false);


func on_ui_aux_2():
	_show_hide_status(!$"Status Area".visible);


func _on_panel_removed():
	super._on_panel_removed();
	if EventManager != null:
		EventManager.set_active_player.disconnect(_set_active_entity);


func _on_button_focus():
	AudioManager.play_sfx("battle_menu_select", 0.1);
	_show_hide_status(false);


func _on_button_down():
	AudioManager.play_sfx("battle_menu_press", 0.1);


func _on_button_up():
	AudioManager.play_sfx("battle_menu_confirm", 0.1);
