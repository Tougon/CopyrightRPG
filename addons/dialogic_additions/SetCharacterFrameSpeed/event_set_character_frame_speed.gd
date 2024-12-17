@tool
extends DialogicEvent
class_name DialogicSetCharacterFrameSpeedEvent

# Define properties of the event here
var object_id := "";
var modifier : float = 1.0;

func _execute() -> void:
	var obj = CutsceneObjectManager.get_object(object_id);
	
	if obj != null:
		var character = obj as RPGCharacter;
		
		if character != null : 
			character.set_frame_speed_modifier(modifier);
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Set Character Frame Speed"
	event_category = "RPG"
	set_default_color('Color2')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "set_character_frame_speed"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"id"		: {"property": "object_id", 	"default": ""},
		"mod"		: {"property": "modifier", 	"default": 1.0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Set Character Frame Speed')
	add_body_edit('object_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Object ID'})
	add_body_edit('modifier', ValueType.NUMBER, {
			'left_text'		: 'Speed Modifier'})

#endregion
