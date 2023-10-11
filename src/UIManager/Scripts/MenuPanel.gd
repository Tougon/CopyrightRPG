extends Panel

class_name MenuPanel

@export var initial_selection : Control;
@export var start_open : bool = false;

var ui_manager;
var tween_player : TweenPlayer;

func _ready():
	ui_manager = UIManager;
	tween_player = $TweenPlayerUI;
	# TODO: Register with the menu manager
	set_active_forced(start_open);
	

func set_active_forced(state : bool):
	if state == true :
		self.show();
		ui_manager.open_menu(self);
	else :
		self.hide();
		ui_manager.close_menu(self);
