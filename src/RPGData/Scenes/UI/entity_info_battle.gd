extends EntityInfoUI
class_name EntityControllerUI

var active : bool = false;


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready();
	EventManager.hide_entity_ui.connect(hide_ui);


func change_hp(new_hp : float):
	if !active : await show_ui();
	
	hp_bar.set_value(new_hp);


func show_ui():
	if tween_player.has_tween("Show"):
		tween_player.play_tween_name("Show");
		await tween_player.tween_ended;
	
	active = true;


func hide_ui():
	active = false;
	
	if tween_player.has_tween("Hide"):
		tween_player.play_tween_name("Hide");
		await tween_player.tween_ended;


func _on_destroy() :
	EventManager.hide_entity_ui.disconnect(hide_ui);
