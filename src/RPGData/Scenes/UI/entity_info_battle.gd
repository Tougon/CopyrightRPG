extends EntityInfoUI
class_name EntityControllerUI

var active : bool = false;


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready();
	EventManager.hide_entity_ui.connect(hide_ui);
	$"Container/HP Bar".visible = false;
	$"Container/MP Bar".visible = false;
	$"Container/Padding".visible = false;


func change_hp(new_hp : float):
	$"Container/HP Bar".visible = true;
	$"Container/Padding".visible = true;
	if !active : await show_ui();
	
	hp_bar.set_value(new_hp);


func change_mp(new_mp : float):
	$"Container/MP Bar".visible = true;
	if !active : await show_ui();
	
	mp_bar.set_value(new_mp);


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
	
	$"Container/HP Bar".visible = false;
	$"Container/MP Bar".visible = false;
	$"Container/Padding".visible = false;


func _on_destroy() :
	EventManager.hide_entity_ui.disconnect(hide_ui);
