extends Panel

class_name MenuPanel

@export var menu_name: String;
@export var start_open : bool = false;
@export var hide_on_unfocus : bool = false;
@export_group("Selections")
@export var initial_selection : Control;
@export var all_selections : Array[Control];
@export_group("Sequencing")
@export var sequence_list: Array[TweenResourceInstance];

var focused : bool;
var ui_manager;
var tween_player : TweenPlayer;

func _ready():
	tree_exiting.connect(_on_destroy);
	
	ui_manager = UIManager;
	ui_manager.add_menu(self);
	
	tween_player = $TweenPlayerUI;
	
	for sequence in sequence_list:
		tween_player.add_tween_runtime(sequence);
	
	set_active_forced(start_open);


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
		
		process_mode = Node.PROCESS_MODE_INHERIT;
		
		if tween_player.has_tween("Focus"):
			tween_player.play_tween_name("Focus");
		
		on_focus();
	
	else :
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
		
		if tween_player.has_tween("Unfocus"):
			tween_player.play_tween_name("Unfocus");
		
		if hide_on_unfocus:
			self.hide();
		
		on_unfocus();


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
	
	if state == true :
		self.show();
		
		if tween_player.has_tween("Open"):
			tween_player.tween_ended.connect(on_tween_end_active);
			tween_player.play_tween_name("Open");
		else :
			on_menu_active();
	
	else :
		set_focus(false);
		
		if tween_player.has_tween("Close"):
			tween_player.tween_ended.connect(on_tween_end_inactive);
			tween_player.play_tween_name("Close");
		else :
			on_menu_inactive();
			self.hide();


func on_tween_end_active(tween_name : String):
	tween_player.tween_ended.disconnect(on_tween_end_active);
	on_menu_active();


func on_tween_end_inactive(tween_name : String):
	tween_player.tween_ended.disconnect(on_tween_end_inactive);
	on_menu_inactive();


func on_menu_active():
	set_focus(true);
	ui_manager.open_menu(self);


func on_menu_inactive():
	ui_manager.close_menu(self);
	self.hide();


func on_menu_cancel():
	set_active(false);


func on_ui_aux_1():
	pass;


func on_ui_aux_2():
	pass;


func _on_destroy():
	if ui_manager != null:
		ui_manager.remove_menu(self);
