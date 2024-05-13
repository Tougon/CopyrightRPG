extends Control

@export var dialogue_canvas : DialogueCanvas;
@export var offset : Vector2;
@export var show_time : float = 1;

var timer = Timer.new();

func _ready():
	self.add_child(timer);
	timer.one_shot = true;
	
	dialogue_canvas.on_dialogue_print.connect(_set_inactive);
	dialogue_canvas.on_dialogue_complete.connect(_set_active);
	dialogue_canvas.on_set_dialogue_end_pos.connect(_set_icon_position);
	visible = false;


func _set_active():
	visible = true;
	_show_hide_routine();


func _set_inactive():
	visible = false;
	timer.timeout.emit();
	timer.timeout.emit();


func _show_hide_routine():
	var delay = show_time;
	$ColorRect/Label.visible = true;
	
	timer.start(delay);
	await timer.timeout;
	
	$ColorRect/Label.visible = false;
	
	timer.start(delay);
	await timer.timeout;
	
	if(visible): _show_hide_routine();


func _set_icon_position(pos : Vector2):
	position = pos;


func _on_destroy():
	if dialogue_canvas != null : 
		dialogue_canvas.on_dialogue_print.disconnect(_set_inactive);
		dialogue_canvas.on_dialogue_complete.disconnect(_set_active);
		dialogue_canvas.on_set_dialogue_end_pos.disconnect(_set_icon_position);
