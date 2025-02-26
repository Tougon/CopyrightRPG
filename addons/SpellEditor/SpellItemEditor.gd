@tool
extends Control
class_name SpellItemEditor;

var current_spell : Spell;
var path : String;
var editor : EditorInterface;

func display_spell(spell : Spell, path : String, editor : EditorInterface):
	current_spell = spell;
	self.path = path;
	self.editor = editor;
	
	if current_spell.spell_name_key == null || current_spell.spell_name_key.is_empty() || current_spell.spell_name_key.length() == 0:
		$HBoxContainer/Label.text = str(path.get_file());
	else :
		$HBoxContainer/Label.text = TranslationServer.get_translation_object("en").get_message(current_spell.spell_name_key);


func remove():
	get_parent().remove_child(self);
	queue_free();


func set_even():
	$BG.modulate = Color(0, 0, 0, 0.2);


func _on_select_button_pressed():
	if editor != null:
		editor.select_file(path);
		editor.get_inspector().resource_selected.emit(current_spell, path)


func _on_delete_button_pressed():
	if editor != null:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path));
		var system = editor.get_resource_filesystem();
		system.filesystem_changed.emit();
		system.scan();
