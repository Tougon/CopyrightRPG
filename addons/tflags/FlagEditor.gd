@tool
extends Control
class_name FlagEditor;

@export var list_item_scene: PackedScene = preload("res://addons/tflags/TFlagItemEditor.tscn");

var flags_list : Array[TFlag];
var flag_to_path = {};
var flag_to_list_item = {};
var editor : EditorInterface;

# NOTE: If a flag is created or destroyed outside of this editor, it won't work properly. We need a refresh

func _ready():
	print("Initializing flags...")
	$"VBoxContainer/Flag Path".text = "assets/Flags"
	_refresh_view();


func _refresh_view():
	for flag in flags_list:
		if flag_to_list_item.has(flag):
			flag_to_list_item[flag].remove();
	
	flags_list.clear();
	flag_to_list_item.clear();
	
	_check_path_for_flags("res://");
	
	for flag in flags_list:
		_create_list_item(flag);


func set_editor(editor : EditorInterface):
	self.editor = editor;
	self.editor.get_resource_filesystem().filesystem_changed.connect(_on_filesystem_changed);


func _on_filesystem_changed():
	_refresh_view();


func _on_create_button_pressed():
	_create_flag();


func _create_flag():
	
	if $"VBoxContainer/Flag Name".text.replace(" ", "") == "":
		printerr("ERROR: Flag key is empty.")
		return;
	
	if _flag_exists($"VBoxContainer/Flag Name".text):
		printerr("ERROR: Flag with the key " + $"VBoxContainer/Flag Name".text + " already exists!")
		return;
	
	var path = $"VBoxContainer/Flag Path".text;
	var dir = DirAccess.open("res://");
	
	if dir != null && !dir.dir_exists(path):
		print("Creating path: " + path);
		dir.make_dir(path)
	
	var flag = TFlag.new();;
	flag.flag_name_key = $"VBoxContainer/Flag Name".text.to_lower();
	var flag_path = "res://" + path + "/" + flag.flag_name_key + ".tres"
	ResourceSaver.save(flag, flag_path);
	flags_list.append(flag);
	flag_to_path[flag] = flag_path;
	
	_create_list_item(flag);


func _create_list_item(flag : TFlag):
	var item = list_item_scene.instantiate() as TFlagItemEditor;
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child(item);
	
	if item:
		item.display_flag(flag, flag_to_path[flag], editor);
		flag_to_list_item[flag] = item;
		
		if $VBoxContainer/ScrollContainer/VBoxContainer.get_child_count() % 2 == 0:
			item.set_even();


func _flag_exists(name : String) -> bool:
	for flag in flags_list:
		if flag.flag_name_key == name.to_lower():
			return true;
	return false;


func _check_path_for_flags(path : String):
	var root = DirAccess.open(path);
	
	if root:
		var dirs = root.get_directories()
		
		for d in dirs:
			_check_path_for_flags(path + d + "/");
		
		var files = root.get_files();
		
		for f in files:
			
			if f.ends_with(".tres"):
				_add_flag(path + f);
			
			#if temp:
				#_check_is_flag(temp.get_as_text());
				#temp.close();
	else:
		print("ERROR: " + path + " does not exist");


func _add_flag(file_name : String):
	var f := FileAccess.open(file_name, FileAccess.READ)
	var text := f.get_as_text()

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
					if value == "TFlag":
						# Load the resource at the given path
						var loaded = ResourceLoader.load(file_name);
						
						if loaded is TFlag:
							flags_list.append(loaded as TFlag);
							flag_to_path[(loaded as TFlag)] = file_name;
							return;
