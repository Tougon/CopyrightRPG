extends ColorRect
class_name EntityInfoUI

enum InfoType { Active, Specific }
enum DisplayType { Full, Restricted }

@export var info_type : InfoType;
@export var display_type : DisplayType;

@onready var tween_player : TweenPlayer = $TweenPlayerUI;
@onready var hp_bar : UnderlayBar = $"Container/HP Bar";
@onready var mp_bar : UnderlayBar = $"Container/MP Bar";

var current_entity : EntityController;


# Called when the node enters the scene tree for the first time.
func _ready():
	if info_type == InfoType.Active:
		EventManager.set_active_player.connect(_set_entity_info);
	
	match display_type:
		DisplayType.Full:
			hp_bar.set_text_visible(true);
			mp_bar.set_bar_visible(true);
		DisplayType.Restricted:
			hp_bar.set_text_visible(false);
			mp_bar.set_bar_visible(false);


func set_specific_entity_info(entity : EntityController, all : bool = false):
	if all:
		if $"Container/Player Name" != null : $"Container/Player Name".text = tr("T_ENTITY_ALL");
		hp_bar.set_bar_visible(false);
	else:
		_set_entity_info(entity);
		hp_bar.set_bar_visible(true);


func _set_entity_info(entity : EntityController):
	# Disconnect the previously selected entity
	if current_entity != null:
		current_entity = null;
	
	current_entity = entity;
	
	if current_entity == null :
		return;
	
	var player_name = get_node_or_null("Container/Player Name");
	
	if player_name != null : player_name.text = entity.param.entity_name;
	hp_bar.set_values_immediate(entity.current_hp, 0, entity.max_hp);
	mp_bar.set_values_immediate(entity.current_mp, 0, entity.max_mp);
