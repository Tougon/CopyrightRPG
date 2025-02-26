@tool
extends Control
class_name EntityEditor;

@export var list_item_scene: PackedScene = preload("res://addons/EntityEditor/EntityItemEditor.tscn");

var entity_list : Array[Entity];
var entity_to_path = {};
var entity_to_list_item = {};
var editor : EditorInterface;

func _ready():
	print("Initializing entities...")
	_refresh_view();


func _refresh_view():
	for entity in entity_list:
		if entity_to_list_item.has(entity):
			entity_to_list_item[entity].remove();
	
	entity_list.clear();
	entity_to_list_item.clear();
	
	_check_path_for_spells("res://assets/Entities/");
	
	# Sort spells by spell name
	entity_list.sort_custom(_compare_name);
	for entity in entity_list:
		_create_list_item(entity);


func _compare_name(a : Entity, b : Entity):
	var a_name = "";
	var b_name = "";
	
	if a.name_key.is_empty() || a.name_key.length() == 0:
		a_name = a.resource_path.get_file();
	else :
		a_name = str(TranslationServer.get_translation_object("en").get_message(a.name_key));
	
	if b.name_key.is_empty() || b.name_key.length() == 0:
		b_name = b.resource_path.get_file();
	else :
		b_name = str(TranslationServer.get_translation_object("en").get_message(b.name_key));
	
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
	dialog.current_dir = "res://assets/Entities/";
	dialog.file_selected.connect(_on_dir_selected);
	add_child(dialog)
	dialog.popup_centered_ratio();


func _on_dir_selected(path : String):
	print(path);
	
	if !path.ends_with(".tres"):
		path += ".tres"
	
	var entity : Entity = Entity.new();
	
	ResourceSaver.save(entity, path);
	entity_list.append(entity);
	entity_to_path[entity] = path;
	
	_create_list_item(entity);
	
	var system = editor.get_resource_filesystem();
	system.filesystem_changed.emit();
	system.scan();


func _create_list_item(entity : Entity):
	var item = list_item_scene.instantiate() as EntityItemEditor;
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child(item);
	
	if item:
		item.display_entity(entity, entity_to_path[entity], editor);
		entity_to_list_item[entity] = item;
		
		if $VBoxContainer/ScrollContainer/VBoxContainer.get_child_count() % 2 == 0:
			item.set_even();


func _entity_exists(name : String) -> bool:
	for entity in entity_list:
		if entity.resource_path.get_file().replace(".tres", "").to_lower() == name.to_lower():
			return true;
	return false;


func _check_path_for_spells(path : String):
	var root = DirAccess.open(path);
	
	if root:
		var dirs = root.get_directories()
		
		for d in dirs:
			_check_path_for_spells(path + d + "/");
		
		var files = root.get_files();
		
		for f in files:
			if f.ends_with(".tres"):
				_add_entity(path + f);
	else:
		print("ERROR: " + path + " does not exist");


func _add_entity(file_name : String):
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
					if value == "Entity" :
						# Load the resource at the given path
						var loaded = ResourceLoader.load(file_name);
						
						if loaded is Entity:
							entity_list.append(loaded as Entity);
							entity_to_path[(loaded as Entity)] = file_name;
							return;
