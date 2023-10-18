extends TweenPlayer

var parent;
var focused : bool = false;
var hovered : bool = false;

func _ready():
	super._ready();
	parent = $"../";
	play_tween_name("Idle");
	
	if parent is BaseButton:
		(parent as BaseButton).pressed.connect(_on_button_pressed);
		(parent as BaseButton).button_down.connect(_on_button_down);
		(parent as BaseButton).button_up.connect(_on_button_up);
		(parent as BaseButton).focus_entered.connect(_on_focus_entered);
		(parent as BaseButton).focus_exited.connect(_on_focus_exited);
		(parent as BaseButton).mouse_entered.connect(_on_mouse_entered);
		(parent as BaseButton).mouse_exited.connect(_on_mouse_exited);


func _on_button_pressed():
	if has_tween("Pressed") :
		next_tween = _get_next_tween();
		play_tween_name("Pressed");
	
func _on_button_down():
	if has_tween("Button Down") :
		next_tween = "";
		play_tween_name("Button Down");
	
func _on_button_up():
	if has_tween("Button Up") :
		next_tween = _get_next_tween();
		play_tween_name("Button Up");
	
func _on_focus_entered():
	focused = true;
	if has_tween("Focus Entered") :
		next_tween = _get_next_tween();
		play_tween_name("Focus Entered");

func _on_focus_exited():
	focused = false;
	if has_tween("Focus Exited") :
		next_tween = _get_next_tween();
		play_tween_name("Focus Exited");

func _on_mouse_entered():
	hovered = true;
	
	UIManager.set_current_hover(parent);
	
	if has_tween("Mouse Entered") :
		next_tween = _get_next_tween();
		play_tween_name("Mouse Entered");

func _on_mouse_exited():
	hovered = false;
	
	if UIManager.current_hover == parent:
		UIManager.set_current_hover(null);
	
	if has_tween("Mouse Exited") :
		next_tween = _get_next_tween();
		play_tween_name("Mouse Exited");

func _get_next_tween():
	if hovered : return "Hover";
	if focused : return "Focus";
	return "Idle";
	
func _get_next_tween_enter():
	if hovered : return "Mouse Entered";
	if focused : return "Focus Entered";
	return "Idle";
