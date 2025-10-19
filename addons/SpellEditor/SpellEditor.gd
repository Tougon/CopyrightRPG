@tool
extends Control
class_name SpellEditor;

@export var list_item_scene: PackedScene = preload("res://addons/SpellEditor/SpellItemEditor.tscn");

var spell_list : Array[Spell];
var spell_to_path = {};
var spell_to_list_item = {};
var editor : EditorInterface;

func _ready():
	print("Initializing spells...")
	_refresh_view();


func _refresh_view():
	for spell in spell_list:
		if spell_to_list_item.has(spell):
			spell_to_list_item[spell].remove();
	
	spell_list.clear();
	spell_to_list_item.clear();
	
	_check_path_for_spells("res://assets/Spells/");
	
	# Sort spells by spell name
	spell_list.sort_custom(_compare_name);
	for spell in spell_list:
		_create_list_item(spell);


func _compare_name(a : Spell, b : Spell):
	var a_name = "";
	var b_name = "";
	
	if a.spell_name_key.is_empty() || a.spell_name_key.length() == 0:
		a_name = a.resource_path.get_file();
	else :
		a_name = str(TranslationServer.get_translation_object("en").get_message(a.spell_name_key));
	
	if b.spell_name_key.is_empty() || b.spell_name_key.length() == 0:
		b_name = b.resource_path.get_file();
	else :
		b_name = str(TranslationServer.get_translation_object("en").get_message(b.spell_name_key));
	
	return a_name < b_name;


func set_editor(editor : EditorInterface):
	self.editor = editor;
	self.editor.get_resource_filesystem().filesystem_changed.connect(_on_filesystem_changed);


func _on_filesystem_changed():
	_refresh_view();


func _on_create_button_pressed():
	_create_spell();


func _create_spell():
	var dialog = FileDialog.new();
	dialog.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE);
	dialog.set_access(FileDialog.ACCESS_RESOURCES);
	dialog.current_dir = "res://assets/Spells/";
	dialog.file_selected.connect(_on_dir_selected);
	add_child(dialog)
	dialog.popup_centered_ratio();


func _on_dir_selected(path : String):
	print(path);
	
	if !path.ends_with(".tres"):
		path += ".tres"
	
	var spell : Spell;
	
	if $"VBoxContainer/Damage Spell".button_pressed :
		spell = DamageSpell.new();
	else :
		spell = Spell.new();
	
	ResourceSaver.save(spell, path);
	spell_list.append(spell);
	spell_to_path[spell] = path;
	
	_create_list_item(spell);
	
	var system = editor.get_resource_filesystem();
	system.filesystem_changed.emit();
	system.scan();


func _create_list_item(spell : Spell):
	var item = list_item_scene.instantiate() as SpellItemEditor;
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child(item);
	
	if item:
		item.display_spell(spell, spell_to_path[spell], editor);
		spell_to_list_item[spell] = item;
		
		if $VBoxContainer/ScrollContainer/VBoxContainer.get_child_count() % 2 == 0:
			item.set_even();


func _spell_exists(name : String) -> bool:
	for spell in spell_list:
		if spell.resource_path.get_file().replace(".tres", "").to_lower() == name.to_lower():
			return true;
	return false;


func _check_path_for_spells(path : String):
	var root = DirAccess.open(path);
	
	if root:
		var dirs = root.get_directories()
		
		for d in dirs:
			if d.contains("reference"):
				continue;
			_check_path_for_spells(path + d + "/");
		
		var files = root.get_files();
		
		for f in files:
			if f.ends_with(".tres"):
				_add_spell(path + f);
	else:
		print("ERROR: " + path + " does not exist");


func _add_spell(file_name : String):
	var s := FileAccess.open(file_name, FileAccess.READ)
	var text := s.get_as_text()

	for line in text.split("\n"):
		
		line = line.rstrip("\r")
		
		if line.find("[gd_resource") == 0 and line.find("]") == line.length()-1:
			
			line = line.substr("[gd_resource".length(), line.length()-2).lstrip(" ").rstrip(" ")
			var entries = line.split(" ")
			
			for entry in entries:
				
				var pair = entry.split("=")
				
				if pair[0] == "script_class":
					var value = pair[1].lstrip("\"").rstrip("\"")
					
					# Check to see if the value is valid
					# NOTE: May need more in depth checks to fetch all spells
					if value == "Spell" || value == "DamageSpell" || value == "InfiniteLoopSpell" || value == "StatDependentSpell":
						# Load the resource at the given path
						var loaded = ResourceLoader.load(file_name);
						
						if loaded is Spell:
							spell_list.append(loaded as Spell);
							spell_to_path[(loaded as Spell)] = file_name;
							return;
