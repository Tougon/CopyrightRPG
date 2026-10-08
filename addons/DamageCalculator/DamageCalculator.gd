@tool
extends Control
class_name DamageCalculator;

@export var attacker : DamageCalculatorEntity;
@export var defender : DamageCalculatorEntity;

var entity_list : Array[Entity];
var spell_list : Array[DamageSpell];

func _ready():
	print("Initializing damage calculator...")
	_refresh_view();


func set_editor(editor : EditorInterface):
	self.editor = editor;
	self.editor.get_resource_filesystem().filesystem_changed.connect(_on_filesystem_changed);


func _refresh_view():
	var valid_entities : Array[Entity];
	
	$"Entity/ScrollContainer/VBoxContainer/Move Select".clear();
	_check_path_for_spells("res://assets/Spells/");
	
	for spell in spell_list :
		if spell != null : 
			var spell_name = TranslationServer.get_translation_object("en").get_message(spell.spell_name_key);
			if spell_name.is_empty() : spell_name = spell.spell_name_key;
			
			$"Entity/ScrollContainer/VBoxContainer/Move Select".add_item(spell_name);
	
	_check_path_for_entities("res://assets/Entities/");
	
	for entity in entity_list:
		if entity != null && !(entity.resource_name.contains("dummy")) :
			valid_entities.append(entity);
	
	if attacker : attacker.initialize(self, valid_entities);
	if defender : defender.initialize(self, valid_entities);


func _on_move_select_item_selected(index: int) -> void:
	var selected_move = spell_list[index];
	update_display(selected_move);


func refresh_display() :
	var current_index = $"Entity/ScrollContainer/VBoxContainer/Move Select".get_item_index($"Entity/ScrollContainer/VBoxContainer/Move Select".get_selected_id());
	update_display(spell_list[current_index]);


func update_display(move : Spell) :
	var user = entity_list[attacker.current_index];
	var target = entity_list[defender.current_index];
	
	var atk_mod = max(2.0, 2.0 + attacker.current_aux_stat_1) / max(2.0, 2.0 - attacker.current_aux_stat_1);
	var mag_mod = max(2.0, 2.0 + attacker.current_aux_stat_2) / max(2.0, 2.0 - attacker.current_aux_stat_2);
	var def_mod = max(2.0, 2.0 + defender.current_aux_stat_1) / max(2.0, 2.0 - defender.current_aux_stat_1);
	var res_mod = max(2.0, 2.0 + defender.current_aux_stat_2) / max(2.0, 2.0 - defender.current_aux_stat_2);
	
	var damage_roll = move.simulate_damage(user, target, attacker.current_level, defender.current_level, atk_mod, mag_mod, def_mod, res_mod);
	
	if damage_roll.size() > 1 :
		$"Entity/ScrollContainer/VBoxContainer/Damage Amt/Min".text = "Min: " + str(damage_roll[0]);
	if damage_roll.size() > 2 :
		$"Entity/ScrollContainer/VBoxContainer/Damage Amt/Average".text = "Avg: " + str(damage_roll[1]);
	if damage_roll.size() > 3 :
		$"Entity/ScrollContainer/VBoxContainer/Damage Amt/Max".text = "Max: " + str(damage_roll[2]);


func _check_path_for_entities(path : String):
	var root = DirAccess.open(path);
	
	if root:
		var dirs = root.get_directories()
		
		for d in dirs:
			_check_path_for_entities(path + d + "/");
		
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
							return;


func _check_path_for_spells(path : String):
	var root = DirAccess.open(path);
	
	if root:
		var dirs = root.get_directories()
		
		for d in dirs:
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
					if value == "DamageSpell" :
						# Load the resource at the given path
						var loaded = ResourceLoader.load(file_name);
						
						if loaded is DamageSpell:
							spell_list.append(loaded as DamageSpell);
							return;


func _on_filesystem_changed():
	_refresh_view();
