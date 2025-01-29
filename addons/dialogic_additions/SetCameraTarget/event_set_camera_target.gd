@tool
extends DialogicEvent
class_name DialogicSetCameraTargetEvent

# Define properties of the event here
var object_id := "";
var camera_priority := 2;

func _execute() -> void:
	if OverworldManager.free_camera == null: finish();
	
	OverworldManager.free_camera.set_priority(roundi(camera_priority));
	
	if object_id.to_lower() == "player":
		OverworldManager.free_camera.follow_target = OverworldManager.player_controller;
	else:
		var obj = CutsceneObjectManager.get_object(object_id);
		
		if obj != null :
			OverworldManager.free_camera.follow_target = obj;
	
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Set Camera Target"
	event_category = "RPG"
	event_sorting_index = 10
	set_default_color('Color3')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "set_camera_target"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"id"		: {"property": "object_id", 	"default": ""},
		"priority"		: {"property": "camera_priority", 	"default": 2},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Set Camera Target')
	add_body_edit('object_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Object ID'})
	add_body_edit('camera_priority', ValueType.NUMBER, {
			'left_text'		: 'Camera Priority'})

#endregion
