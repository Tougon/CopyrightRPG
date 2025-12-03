@tool
extends Control
class_name EntityEditor;

@export var list_item_scene: PackedScene = preload("res://addons/EntityEditor/EntityItemEditor.tscn");

var entity_list : Array[Entity];
var entity_to_path = {};
var entity_to_list_item = {};
var editor : EditorInterface;
var _is_importing : bool = false;

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


func _on_export_to_csv_pressed() -> void:
	_is_importing = false;
	
	var dialog = FileDialog.new();
	dialog.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE);
	dialog.set_access(FileDialog.ACCESS_RESOURCES);
	dialog.current_dir = "res://";
	dialog.file_selected.connect(_on_csv_dir_selected);
	add_child(dialog)
	dialog.popup_centered_ratio();



func _on_csv_dir_selected(path : String):
	print(path);
	
	if !_is_importing :
		if !path.ends_with(".csv"):
			path += ".csv"
		
		var file : FileAccess;
		file = FileAccess.open(path, FileAccess.WRITE);
		
		var csv_header = "Name Key,Name,LVL Min,LVL Max,HP Min,HP Max,MP Min,MP Max,ATK Min,ATK Max,DEF Min,DEF Max,MAG Min,MAG Max,RES Min,RES Max,SPD Min,SPD Max,EXP Min,EXP Max";
		file.store_csv_line(csv_header.split(","));
		
		for entity in entity_list:
			var entity_name = TranslationServer.get_translation_object("en").get_message(entity.name_key);
			var csv_output = entity.name_key + "," + entity_name + "," + str(entity.min_level) + "," + str(entity.max_level) + "," + str(entity.hp.min) + "," + str(entity.hp.max) + "," + str(entity.mp.min) + "," + str(entity.mp.max) + "," + str(entity.atk.min) + "," + str(entity.atk.max) + "," + str(entity.def.min) + "," + str(entity.def.max) + "," + str(entity.sp_atk.min) + "," + str(entity.sp_atk.max) + "," + str(entity.sp_def.min) + "," + str(entity.sp_def.max) + "," + str(entity.spd.min) + "," + str(entity.spd.max) + ",";
			
			if entity.reward_exp != null :
				csv_output += str(entity.reward_exp.min) + "," + str(entity.reward_exp.max);
			else :
				csv_output += "0,0";
			
			file.store_csv_line(csv_output.split(","));
		
		file.close();
	
	else:
		print("IMPORT")
		if !path.ends_with(".csv"):
			return;
		
		var file : FileAccess;
		file = FileAccess.open(path, FileAccess.READ);
		
		var header = file.get_csv_line(",");
		
		while !file.eof_reached():
			var line = file.get_csv_line(",");
			
			for entity in entity_list :
				if entity.name_key == line[0]:
					print("UPDATING " + line[1]);
					
					entity.min_level = line[2].to_int();
					entity.max_level = line[3].to_int();
					
					entity.hp.max = line[5].to_int();
					entity.hp.min = line[4].to_int();
					entity.mp.max = line[7].to_int();
					entity.mp.min = line[6].to_int();
					
					entity.atk.max = line[9].to_int();
					entity.atk.min = line[8].to_int();
					entity.def.max = line[11].to_int();
					entity.def.min = line[10].to_int();
					entity.sp_atk.max = line[13].to_int();
					entity.sp_atk.min = line[12].to_int();
					entity.sp_def.max = line[15].to_int();
					entity.sp_def.min = line[14].to_int();
					entity.spd.max = line[17].to_int();
					entity.spd.min = line[16].to_int();
					
					if entity.reward_exp != null :
						entity.reward_exp.max = line[19].to_int();
						entity.reward_exp.min = line[18].to_int();
		
		file.close();


func _on_import_from_csv_pressed() -> void:
	_is_importing = true;
	
	var dialog = FileDialog.new();
	dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE);
	dialog.set_access(FileDialog.ACCESS_RESOURCES);
	dialog.current_dir = "res://";
	dialog.file_selected.connect(_on_csv_dir_selected);
	add_child(dialog)
	dialog.popup_centered_ratio();
