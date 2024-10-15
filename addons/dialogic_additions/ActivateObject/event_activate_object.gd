@tool
extends DialogicEvent
class_name DialogicActivateObjectEvent

# Define properties of the event here
var object_id := "";
var active_state := false;

func _execute() -> void:
	var obj = CutsceneObjectManager.get_object(object_id);
	
	if obj != null:
		obj.set_object_active(active_state);
	
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Activate Object"
	event_category = "RPG"
	set_default_color('Color2')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "activate_object"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"id"		: {"property": "object_id", 	"default": ""},
		"active"		: {"property": "active_state", 	"default": false},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Activate Object')
	add_body_edit('object_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Object ID'})
	add_body_edit('active_state', ValueType.BOOL, {
			'left_text'		: 'Active State'})

#endregion
