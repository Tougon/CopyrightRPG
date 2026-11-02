extends Control

const SKIT_ANIM_TIME : float = 2.0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer.modulate = Color(0.0, 0.0, 0.0, 0.0);
	EventManager.show_skit_ui.connect(_on_skit_show);


func _on_skit_show(skit_name : String, show : bool):
	$HBoxContainer/Label.text = skit_name;
	
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	
	if show : 
		tween.tween_property($HBoxContainer, "modulate", Color.WHITE, SKIT_ANIM_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	else :
		tween.tween_property($HBoxContainer, "modulate", Color(0.0, 0.0, 0.0, 0.0), SKIT_ANIM_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
