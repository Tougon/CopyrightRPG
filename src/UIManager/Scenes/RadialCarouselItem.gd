extends Control
class_name RadialCarouselItem;

var _intended_angle : float = 0.0;
var _angle : float = 0.0;
var owning_carousel : RadialCarousel;

func set_angle(angle : float) :
	_angle = angle;
	var pos = owning_carousel.get_position_from_angle(_angle);
	position = pos;

func get_angle() -> float:
	return _angle;

func set_intended_angle(angle : float) :
	_intended_angle = angle;

func get_intended_angle() -> float:
	return _intended_angle;

# Eventually will pass
func set_data(obj) :
	if obj is String:
		$Label.text = obj as String;


# Input/Selection
func set_highlight(active : bool) :
	pass; 
