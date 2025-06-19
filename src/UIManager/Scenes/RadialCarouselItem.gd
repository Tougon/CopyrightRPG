extends Control
class_name RadialCarouselItem;

var _carousel_angle : float = 0.0;
var owning_carousel : RadialCarousel;

func set_angle(angle : float) :
	_carousel_angle = angle;
	var pos = owning_carousel.get_position_from_angle(_carousel_angle);
	position = pos;


# Eventually will pass
func set_data(obj) :
	if obj is String:
		$Label.text = obj as String;

# Need skeleton functions for on highlight, unhighlight


func get_angle() -> float:
	return _carousel_angle;
