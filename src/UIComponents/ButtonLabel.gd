extends Label

var _button : Button;
var _colors : Dictionary;
@export var override_pressed : bool = false;
@export var override_pressed_color : Color = Color(0.8, 0.412, 0);

func _ready() -> void:
	_button = get_parent() as Button;
	
	if _button != null :
		_button.button_down.connect(_on_button_down);
		_button.button_up.connect(_on_button_up);
		_button.focus_entered.connect(_on_button_focus_entered);
		_button.focus_exited.connect(_on_button_focus_exited);
		
		var color_type = _button.theme.get_color_type_list();
		for ct in color_type :
			var clrs = _button.theme.get_color_list(ct);
			for c in clrs :
				var clr = _button.theme.get_color(c, ct);
				_colors[c] = clr;
				print(c);
				print(clr);


func _on_button_focus_entered():
	if _button.disabled : 
		self_modulate = _colors["font_disabled_color"];
	else : 
		self_modulate = _colors["font_focus_color"];


func _on_button_focus_exited():
	if _button.disabled : 
		self_modulate = _colors["font_disabled_color"];
	else : 
		self_modulate = _colors["font_color"];


func _on_button_down():
	if _button.disabled : 
		self_modulate = _colors["font_disabled_color"];
	else : 
		if override_pressed : 
			self_modulate = override_pressed_color;
		else :
			self_modulate = _colors["font_pressed_color"];


func _on_button_up():
	if _button.disabled : 
		self_modulate = _colors["font_disabled_color"];
	else : 
		if UIManager.current_selection == _button :
			self_modulate = _colors["font_focus_color"];
		else :
			self_modulate = _colors["font_color"];
