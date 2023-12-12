extends ColorRect
class_name EntityInfoUI

enum InfoType { Active, Specific }
enum DisplayType { Full, Restricted }

@export var info_type : InfoType;
@export var display_type : DisplayType;
var current_entity : EntityController;

# Called when the node enters the scene tree for the first time.
func _ready():
	if info_type == InfoType.Active:
		EventManager.set_active_player.connect(_set_entity_info);
	
	match display_type:
		DisplayType.Full:
			$"HBoxContainer/HP Bar/ColorRect/VBoxContainer/RichTextLabel".visible = true;
			$"HBoxContainer/MP Bar/ColorRect".visible = true;
		DisplayType.Restricted:
			$"HBoxContainer/HP Bar/ColorRect/VBoxContainer/RichTextLabel".visible = false;
			$"HBoxContainer/MP Bar/ColorRect".visible = false;


func set_specific_entity_info(entity : EntityController, all : bool):
	if all:
		$"HBoxContainer/Player Name".text = tr("T_NAME_ALL");
		$"HBoxContainer/HP Bar/ColorRect".visible = false;
	else:
		_set_entity_info(entity);
		$"HBoxContainer/HP Bar/ColorRect".visible = true;

func _set_entity_info(entity : EntityController):
	# Disconnect the previously selected entity
	if current_entity != null:
		current_entity = null;
	
	current_entity = entity;
	
	# TODO: Connect to damage functions
	# TODO: Leading zeroes
	$"HBoxContainer/Player Name".text = entity.param.entity_name;
	$"HBoxContainer/HP Bar/ColorRect/VBoxContainer/RichTextLabel".text = "[b]HP: [color=FFFF00]" + str(entity.current_hp) + "[/color]/" + str(entity.max_hp);
	$"HBoxContainer/MP Bar/ColorRect/VBoxContainer/RichTextLabel".text = "[b]MP: [color=FFFF00]" + str(entity.current_mp) + "[/color]/" + str(entity.max_mp);
	$"HBoxContainer/HP Bar/ColorRect/ColorRect".scale.x = entity.get_hp_percent();
	$"HBoxContainer/MP Bar/ColorRect/ColorRect".scale.x = entity.get_mp_percent();
	
