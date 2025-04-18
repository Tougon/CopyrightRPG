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


func _enter_tree():
	super._enter_tree();
	
	EventManager.set_active_player.connect(_set_active_entity);


func on_tween_end_active(tween_name : String):
	super.on_tween_end_active(tween_name);
	
	# TODO: Re-evaluate?
	#var msg = tr("T_BATTLE_TURN_READY").format({entity = current_entity.param.entity_name});
	#EventManager.on_message_queue.emit(msg);


func _set_active_entity(entity : EntityController):
	current_entity = entity;
	
	atk_display.set_stat_display_value(current_entity.atk_stage);
	def_display.set_stat_display_value(current_entity.def_stage);
	mag_display.set_stat_display_value(current_entity.sp_atk_stage);
	res_display.set_stat_display_value(current_entity.sp_def_stage);
	spd_display.set_stat_display_value(current_entity.spd_stage);
	acc_display.set_stat_display_value(current_entity.accuracy_stage);
	eva_display.set_stat_display_value(current_entity.evasion_stage);


func on_focus():
	# TODO: As we add more options to the menu, this must be expanded.
	if current_entity != null && (current_entity is PlayerController):
		match (current_entity.prev_action_type):
			PlayerController.ActionType.ATTACK:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Attack";
			PlayerController.ActionType.DEFEND:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Defend";
			PlayerController.ActionType.SPELL:
				initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Magic";
			PlayerController.ActionType.ITEM:
				if current_entity.has_any_items:
					initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Item";
		
	else:
		initial_selection = $"BG Area/Player Options/ScrollContainer/GridContainer/Attack";
	
	$"BG Area/Player Options/ScrollContainer/GridContainer/Item".disabled = !current_entity.has_any_items();
	$"BG Area/Player Options/ScrollContainer".ensure_control_visible(initial_selection);


func _on_attack_button_pressed():
	EventManager.on_attack_select.emit();


func _on_defend_button_pressed():
	EventManager.on_defend_select.emit();


func _on_magic_button_pressed():
	EventManager.on_magic_select.emit();


func _on_item_button_pressed():
	EventManager.on_item_select.emit();


func on_menu_cancel():
	EventManager.player_menu_cancel.emit();

func on_unfocus():
	$"Status Area".visible = false;

func on_ui_aux_1():
	$"Status Area".visible = !$"Status Area".visible;

func _on_panel_removed():
	super._on_panel_removed();
	if EventManager != null:
		EventManager.set_active_player.disconnect(_set_active_entity);
