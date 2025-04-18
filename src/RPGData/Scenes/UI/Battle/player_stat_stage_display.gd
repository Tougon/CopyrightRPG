extends Control
class_name PlayerStatStageDisplay

@export var icon_size : float = 32;
@export var separation : float = 5;
@export var center_v : bool = true;
@export var filled_texture : Texture2D;
@export var empty_texture : Texture2D;

var stat_icons : Array[TextureRect];
var current_stage : int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var x_pos = 0.0;
	var y_pos = 0.0;
	if center_v : y_pos = (size.y / 2.0) - (icon_size);
	print(y_pos)
	
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
		
		stat_icon.size = Vector2(icon_size, icon_size);
		stat_icon.custom_minimum_size = Vector2(icon_size, icon_size);
		
		self.add_child(stat_icon);
		stat_icons.append(stat_icon);
		
		stat_icon.position = Vector2(x_pos, y_pos);
		x_pos += icon_size + separation;


func set_stat_display_value(stage : int):
	var color = Color.WHITE;
	
	if stage > 0 : color = lerp(Color(1, 0.5, 0.5), Color.RED, (stage as float) / (EntityController.STAT_STAGE_LIMIT as float))
	elif  stage < 0 : color = lerp(Color(0.5, 0.5, 1), Color.BLUE, (-stage as float) / (EntityController.STAT_STAGE_LIMIT as float))
	
	stage += EntityController.STAT_STAGE_LIMIT;
	current_stage = stage;
	
	for i in stat_icons.size():
		if i == stage :
			stat_icons[i].texture = filled_texture;
			stat_icons[i].modulate = color;
		else :
			stat_icons[i].texture = empty_texture;
			stat_icons[i].modulate = Color.WHITE;
