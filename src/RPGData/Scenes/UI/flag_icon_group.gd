extends Control
class_name FlagIconGroup

@export var flags : Array[TFlag];
@onready var icon_root : Control = $"Icon Container";

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


func set_sealing(sealing : bool):
	for icon in _icons:
		icon.get_child(0).visible = sealing;
