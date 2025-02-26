@tool
extends Control
class_name EffectEditor;

@export var list_item_scene: PackedScene = preload("res://addons/EffectEditor/EffectItemEditor.tscn");

var effect_list : Array[Effect];
var effect_to_path = {};
var effect_to_list_item = {};
var editor : EditorInterface;

func _ready():
	print("Initializing effects...")
	_refresh_view();


func _refresh_view():
	for effect in effect_list:
		if effect_to_list_item.has(effect):
			effect_to_list_item[effect].remove();
	
	effect_list.clear();
	effect_to_list_item.clear();
	
	_check_path_for_effects("res://assets/Effects/");
	
	# Sort spells by spell name
	effect_list.sort_custom(_compare_name);
	for effect in effect_list:
		_create_list_item(effect);


func _compare_name(a : Effect, b : Effect):
	var a_name = a.resource_path.get_file();
	var b_name = b.resource_path.get_file();
	
	return a_name < b_name;


func set_editor(editor : EditorInterface):
	self.editor = editor;
	self.editor.get_resource_filesystem().filesystem_changed.connect(_on_filesystem_changed);


func _on_filesystem_changed():
	_refresh_view();


func _on_create_button_pressed():
	_create_effect();


func _create_effect():
	var dialog = FileDialog.new();
	dialog.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE);
	dialog.set_access(FileDialog.ACCESS_RESOURCES);
	dialog.current_dir = "res://assets/Effects/";
	dialog.file_selected.connect(_on_dir_selected);
	add_child(dialog)
	dialog.popup_centered_ratio();


func _on_dir_selected(path : String):
	print(path);
	
	if !path.ends_with(".tres"):
		path += ".tres"
	
	var effect : Effect = Effect.new();
	
	ResourceSaver.save(effect, path);
	effect_list.append(effect);
	effect_to_path[effect] = path;
	
	_create_list_item(effect);
	
	var system = editor.get_resource_filesystem();
	system.filesystem_changed.emit();
	system.scan();


func _create_list_item(effect : Effect):
	var item = list_item_scene.instantiate() as EffectItemEditor;
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child(item);
	
	if item:
		item.display_effect(effect, effect_to_path[effect], editor);
		effect_to_list_item[effect] = item;
		
		if $VBoxContainer/ScrollContainer/VBoxContainer.get_child_count() % 2 == 0:
			item.set_even();
	else : 
		print("guh, what the heck?")


func _effect_exists(name : String) -> bool:
	for effect in effect_list:
		if effect.resource_path.get_file().replace(".tres", "").to_lower() == name.to_lower():
			return true;
	return false;


func _check_path_for_effects(path : String):
	var root = DirAccess.open(path);
	
	if root:
		var dirs = root.get_directories()
		
		for d in dirs:
			_check_path_for_effects(path + d + "/");
		
		var files = root.get_files();
		
		for f in files:
			if f.ends_with(".tres"):
				_add_effect(path + f);
	else:
		print("ERROR: " + path + " does not exist");


func _add_effect(file_name : String):
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
					if value == "Effect" :
						# Load the resource at the given path
						var loaded = ResourceLoader.load(file_name);
						
						if loaded is Effect:
							effect_list.append(loaded as Effect);
							effect_to_path[(loaded as Effect)] = file_name;
							return;
