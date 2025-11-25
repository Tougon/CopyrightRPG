@tool
extends DialogicEvent
class_name DialogicPlaySoundClipEvent

# Define properties of the event here
var sfx_id := "";
var pitch_range := 0.0;

func _execute() -> void:
	AudioManager.play_sfx(sfx_id, pitch_range);
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Play Sound Clip"
	event_category = "RPG"
	event_sorting_index = 100
	set_default_color('Color6')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "play_sound_clip"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		#"my_parameter"		: {"property": "property", "default": "Default"},
		"sfx"		: {"property": "sfx_id", 	"default": ""},
		"pitch"		: {"property": "pitch_range", 	"default": 0.0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Play Sound Clip')
	add_body_edit('sfx_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'SFX ID'})
	add_body_edit('pitch_range', ValueType.NUMBER, {
			'left_text'		: 'Pitch Range'})

#endregion
