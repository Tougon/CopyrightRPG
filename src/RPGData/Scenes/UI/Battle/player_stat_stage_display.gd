extends Control
class_name PlayerStatStageDisplay

@export var icon_size : float = 32;
@export var separation : float = 5;
@export var filled_texture : Texture2D;
@export var empty_texture : Texture2D;

var stat_icons : Array[TextureRect];
var current_stage : int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var x_pos = ((-EntityController.STAT_STAGE_LIMIT) * icon_size) + (-separation * (EntityController.STAT_STAGE_LIMIT - 1));
	
	for i in (EntityController.STAT_STAGE_LIMIT * 2) + 1:
		var stat_icon = TextureRect.new();
		
		stat_icon.name = "Icon " + str(i + 1);
		stat_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;
		stat_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;
		
		if i == EntityController.STAT_STAGE_LIMIT :
			current_stage = i;
			stat_icon.texture = filled_texture;
		else :
			stat_icon.texture = empty_texture;
		
		stat_icon.position = Vector2(x_pos, 0);
		x_pos += icon_size + separation;
		
		stat_icon.size = Vector2(icon_size, icon_size);
		stat_icon.custom_minimum_size = Vector2(icon_size, icon_size);
		
		self.add_child(stat_icon);
		stat_icons.append(stat_icon);


func set_stat_display_value(stage : int):
	stage += EntityController.STAT_STAGE_LIMIT;
	current_stage = stage;
	
	for i in stat_icons.size():
		if i == stage :
			stat_icons[i].texture = filled_texture;
		else :
			stat_icons[i].texture = empty_texture;
