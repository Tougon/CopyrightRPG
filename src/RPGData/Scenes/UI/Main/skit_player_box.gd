extends Control
class_name SkitPlayerBox;

const PORTRAIT_SCALE_DEFAULT : Vector2 = Vector2(0.9, 0.9);
const PORTRAIT_SCALE_SPEAKING : Vector2 = Vector2(1.0, 1.0);

@export var speaker_name : String;
@export var border_color_default : Color;
@export var border_color_speaking : Color;
@export var bg_color_default : Color;
@export var bg_color_speaking : Color;
@export var portrait_color_default : Color;
@export var portrait_color_speaking : Color;

var _portrait_pos : Vector2;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Border.modulate = border_color_default;
	$BG.modulate = bg_color_default;
	scale = PORTRAIT_SCALE_DEFAULT;


func set_speaking(speaking : bool) :
	if speaking:
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		
		tween.tween_property($Border, "modulate", border_color_speaking, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		tween.tween_property($BG, "modulate", bg_color_speaking, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		tween.tween_property(self, "scale", PORTRAIT_SCALE_SPEAKING, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	else :
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		
		tween.tween_property($Border, "modulate", border_color_default, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		tween.tween_property($BG, "modulate", bg_color_default, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		tween.tween_property(self, "scale", PORTRAIT_SCALE_DEFAULT, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);


func initialize_portrait (portrait : CanvasItem) :
	_portrait_pos = portrait.get_child(0).position;
	portrait.get_child(0).scale = PORTRAIT_SCALE_DEFAULT;
	portrait.get_child(0).position = _portrait_pos + Vector2(19, 19);
	portrait.modulate = portrait_color_default;


func tween_portrait (portrait : CanvasItem, speaking : bool) :
	if speaking:
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		
		tween.tween_property(portrait, "modulate", portrait_color_speaking, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		tween.tween_property(portrait.get_child(0), "scale", PORTRAIT_SCALE_SPEAKING, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		tween.tween_property(portrait.get_child(0), "position", _portrait_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	else :
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		
		tween.tween_property(portrait, "modulate", portrait_color_default, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		tween.tween_property(portrait.get_child(0), "scale", PORTRAIT_SCALE_DEFAULT, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
		tween.tween_property(portrait.get_child(0), "position", _portrait_pos + Vector2(19, 19), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
