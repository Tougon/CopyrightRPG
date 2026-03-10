@tool
extends DialogicEvent
class_name DialogicCustomClearEvent

# Define properties of the event here

func _execute() -> void:
	dialogic.Text.hide_textbox()
	dialogic.Portraits.leave_all_characters();
	await dialogic.get_tree().create_timer(0.5).timeout
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	set_default_color('Color9')
	event_name = "Custom Clear"
	event_category = "RPG"
	event_sorting_index = 500



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "custom_clear"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		#"my_parameter"		: {"property": "property", "default": "Default"},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Custom Clear')

#endregion
