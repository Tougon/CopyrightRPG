extends Panel

class_name MenuPanel

@export var menu_name: String;
@export var start_open : bool = false;
@export var hide_on_unfocus : bool = false;
@export var hide_when_inactive : bool = true;
@export var unfocus_on_open : bool = true;
@export var submenu : bool = false;
@export_group("Selections")
@export var initial_selection : Control;
@export var all_selections : Array[Control];
@export_group("Sequencing")
@export var sequence_list: Array[TweenResourceInstance];

var focused : bool;
var _is_tweening_open : bool;
var _is_tweening_close : bool;
var ui_manager;
var tween_player : TweenPlayer;


func _ready():
	tree_exiting.connect(_on_panel_removed);
	
	if has_node("TweenPlayerUI"):
		tween_player = $TweenPlayerUI;
	
	if tween_player != null :
		for sequence in sequence_list:
			tween_player.add_tween_runtime(sequence);
	
	set_active_forced(start_open);


func _enter_tree():
	ui_manager = UIManager;
	ui_manager.add_menu(self);


func set_active_forced(state : bool):
	if state :
		self.show();
		on_menu_active();
	else :
		on_menu_inactive();


func set_focus(state : bool):
	focused = state;
	
	if focused : 
		if hide_on_unfocus:
			self.show();
			
		for selection in all_selections:
			selection.mouse_filter = Control.MOUSE_FILTER_STOP;
		
		process_mode = Node.PROCESS_MODE_ALWAYS;
		
		if tween_player != null && tween_player.has_tween("Focus"):
			tween_player.play_tween_name("Focus");
		
		on_focus();
	
	else :
		on_unfocus();
		
		for selection in all_selections:
			
			if selection == UIManager.current_hover:
				var tween_player = selection.get_node("TweenPlayerUI");
				
				if tween_player != null:
					var mouse_position = get_viewport().get_mouse_position();
					Input.warp_mouse(Vector2(0, 0));
					selection.mouse_exited.emit();
					selection.draw.emit();
					UIManager.set_current_hover(null);
					Input.warp_mouse(mouse_position);
			
			selection.mouse_filter = Control.MOUSE_FILTER_STOP;
		
		process_mode = Node.PROCESS_MODE_DISABLED;
		
		if tween_player != null && tween_player.has_tween("Unfocus"):
			tween_player.play_tween_name("Unfocus");
		
		if hide_on_unfocus:
			self.hide();


func on_focus():
	pass;


func on_unfocus():
	pass;


func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr


func set_active(state : bool):
	ui_manager.suspend_selection();
	
	if _is_tweening_open :
		_is_tweening_open = false;
		tween_player.tween_ended.disconnect(on_tween_end_active);
	
	if _is_tweening_close :
		_is_tweening_close = false;
		tween_player.tween_ended.disconnect(on_tween_end_inactive);
	
	if state == true :
		self.show();
		
		if tween_player != null && tween_player.has_tween("Open"):
			tween_player.tween_ended.connect(on_tween_end_active);
			_is_tweening_open = true;
			tween_player.play_tween_name("Open");
		else :
			on_menu_active();
		
		UIManager.on_menu_opened.emit(self);
	
	else :
		set_focus(false);
		UIManager.on_menu_closing.emit(self);
		
		if tween_player != null && tween_player.has_tween("Close"):
			tween_player.tween_ended.connect(on_tween_end_inactive);
			_is_tweening_close = true;
			tween_player.play_tween_name("Close");
		else :
			on_menu_inactive();
			self.hide();


func on_tween_end_active(tween_name : String):
	_is_tweening_open = false;
	tween_player.tween_ended.disconnect(on_tween_end_active);
	on_menu_active();


func on_tween_end_inactive(tween_name : String):
	_is_tweening_close = false;
	tween_player.tween_ended.disconnect(on_tween_end_inactive);
	on_menu_inactive();


func on_menu_active():
	set_focus(true);
	ui_manager.open_menu(self);


func on_menu_inactive():
	ui_manager.close_menu(self);
	
	if hide_when_inactive :
		self.hide();


func on_menu_cancel():
	set_active(false);


func on_ui_aux_1():
	pass;


func on_ui_aux_2():
	pass;


func on_ui_trigger_l():
	pass;


func on_ui_trigger_r():
	pass;


func _on_panel_removed():
	if ui_manager != null:
		ui_manager.remove_menu(self);
