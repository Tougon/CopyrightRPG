@tool
extends DialogicEvent
class_name DialogicPlayObjectAnimationEvent

# Define properties of the event here
var object_id := "";
var animation_name := "";
var is_tween := true;

func _execute() -> void:
	var obj = CutsceneObjectManager.get_object(object_id);
	
	if obj != null:
		if is_tween : obj.play_tween(animation_name);
		else : obj.play_animation(animation_name);
	
	# TODO: Optional delay
	
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Play Object Animation"
	event_category = "RPG"
	set_default_color('Color2')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "play_object_animation"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"id"		: {"property": "object_id", 	"default": ""},
		"anim_name"		: {"property": "animation_name", 	"default": ""},
		"tween"		: {"property": "is_tween", 	"default": true},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Play Object Animation')
	add_body_edit('object_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Object ID'})
	add_body_edit('animation_name', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Animation Name'})
	add_body_edit('is_tween', ValueType.BOOL, {
			'left_text'		: 'Is Tween?'})

#endregion
