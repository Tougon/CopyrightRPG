@tool
extends Control
class_name TFlagItemEditor;

var current_flag : TFlag;
var path : String;
var editor : EditorInterface;

func display_flag(flag : TFlag, path : String, editor : EditorInterface):
	current_flag = flag;
	self.path = path;
	self.editor = editor;
	$HBoxContainer/Label.text = current_flag.flag_name_key;

func remove():
	get_parent().remove_child(self);
	queue_free();

func set_even():
	$BG.modulate = Color(0, 0, 0, 0.2);


func _on_select_button_pressed():
	if editor != null:
		editor.select_file(path);
		editor.get_inspector().resource_selected.emit(current_flag, path)


func _on_delete_button_pressed():
	if editor != null:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path));
		editor.get_resource_filesystem().filesystem_changed.emit();
