@tool
extends DialogicEvent
class_name DialogicProgressQuestEvent

var quest_name := "";

func _execute() -> void:
	if quest_name != null && quest_name != "" :
		var step = QuestManager.get_current_step(quest_name);
		
		if step != null :
			var id = QuestManager.get_quest_id(quest_name);
			QuestManager.complete_step(id, step);
	
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Progress Quest"
	event_category = "RPG"
	event_sorting_index = 60



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "progress_quest"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"quest"		: {"property": "quest_name", 	"default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Progress Quest')
	add_body_edit('quest_name', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Quest Name'})

#endregion
