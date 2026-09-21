extends Control
class_name FlagIconGroup

@export var flags : Array[TFlag];
@onready var icon_root : Control = $"Icon Container";
@export var resize_icons : bool = true;

var _icons : Array[TextureRect];

func _ready():
	for icon in icon_root.get_children() :
		var i = icon as TextureRect;
		
		if i != null :
			_icons.append(i);
	
	set_sealing(false);


func display_flags(flags_to_display : Array[TFlag]):
	for i in flags.size():
		_icons[i].visible = flags_to_display.has(flags[i]);
		
		if _icons[i].visible :
			var index = flags_to_display.find(flags[i]);
			_icons[i].get_parent().move_child(_icons[i], index);
			
			if index == 0 && resize_icons:
				_icons[i].get_child(0).scale = Vector2.ONE * 1.25;
				_icons[i].get_child(0).position.x = -3;
				_icons[i].get_child(0).position.y = -2;
			else :
				_icons[i].get_child(0).scale = Vector2.ONE;
				_icons[i].get_child(0).position.x = 0;
				_icons[i].get_child(0).position.y = 0;


func clear_flags():
	for i in flags.size():
		_icons[i].visible = false;


func set_sealing(sealing : bool):
	for icon in _icons:
		icon.get_child(0).get_child(0).visible = sealing;
