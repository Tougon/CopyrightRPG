@tool
extends Control
class_name EntityItemEditor;

var current_entity : Entity;
var path : String;
var editor : EditorInterface;

func display_entity(entity : Entity, path : String, editor : EditorInterface):
	current_entity = entity;
	self.path = path;
	self.editor = editor;
	
	if current_entity.name_key == null || current_entity.name_key.is_empty() || current_entity.name_key.length() == 0:
		$HBoxContainer/Label.text = str(path.get_file());
	else :
		$HBoxContainer/Label.text = TranslationServer.get_translation_object("en").get_message(current_entity.name_key);


func remove():
	get_parent().remove_child(self);
	queue_free();


func set_even():
	$BG.modulate = Color(0, 0, 0, 0.2);


func _on_select_button_pressed():
	if editor != null:
		editor.select_file(path);
		editor.get_inspector().resource_selected.emit(current_entity, path)


func _on_delete_button_pressed():
	if editor != null:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path));
		var system = editor.get_resource_filesystem();
		system.filesystem_changed.emit();
		system.scan();
