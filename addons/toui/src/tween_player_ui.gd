extends TweenPlayer

var focused : bool = false;
var hovered : bool = false;

func _ready():
	super._ready();
	var parent = $"../";
	#play_tween_name("Idle");
	
	if parent is BaseButton:
		(parent as BaseButton).pressed.connect(_on_button_pressed);
		(parent as BaseButton).button_down.connect(_on_button_down);
		(parent as BaseButton).button_up.connect(_on_button_up);
		(parent as BaseButton).focus_entered.connect(_on_focus_entered);
		(parent as BaseButton).focus_exited.connect(_on_focus_exited);
		(parent as BaseButton).mouse_entered.connect(_on_mouse_entered);
		(parent as BaseButton).mouse_exited.connect(_on_mouse_exited);


func _on_button_pressed():
	next_tween = _get_next_tween();
	play_tween_name("Pressed");
	
func _on_button_down():
	next_tween = "";
	play_tween_name("Button Down");
	
func _on_button_up():
	next_tween = _get_next_tween();
	play_tween_name("Button Up");
	
func _on_focus_entered():
	focused = true;
	next_tween = _get_next_tween();
	print(next_tween + " is queued");
	play_tween_name("Focus Entered");
	
func _on_focus_exited():
	focused = false;
	next_tween = _get_next_tween();
	play_tween_name("Focus Exited");
	
func _on_mouse_entered():
	hovered = true;
	next_tween = _get_next_tween();
	play_tween_name("Mouse Entered");
	
func _on_mouse_exited():
	hovered = false;
	next_tween = _get_next_tween();
	play_tween_name("Mouse Exited");

func _get_next_tween():
	if hovered : return "Hover";
	if focused : return "Focus";
	return "Idle";
