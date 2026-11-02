@tool
extends DialogicEvent
class_name DialogicQueueSkitEvent

var skit_name := "";

func _execute() -> void:
	EventManager.queue_skit.emit(skit_name);
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Queue Skit"
	event_category = "RPG"
	event_sorting_index = 90



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "queue_skit"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"skit"		: {"property": "skit_name", 	"default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Queue Skit')
	add_body_edit('skit_name', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Skit Name'})

#endregion
