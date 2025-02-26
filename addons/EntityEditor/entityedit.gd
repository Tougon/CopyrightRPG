@tool
extends EditorPlugin

# A class member to hold the dock during the plugin life cycle.
var dock

func _enter_tree():
	var interface = get_editor_interface();
	
	dock = preload("res://addons/EntityEditor/EntityEditor.tscn").instantiate()
	(dock as EntityEditor).set_editor(interface);
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
