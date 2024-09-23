@tool
extends DialogicEvent
class_name DialogicBeginQuestEvent

# Define properties of the event here
var quest_name := "";


func _execute() -> void:
	var quest_resource = DataManager.quest_database.get_quest_resource(quest_name);
	
	if quest_resource != null :
		if QuestManager.get_player_quest(quest_name).size() <= 0:
			print("Activated quest: " + quest_name);
			QuestManager.add_quest(quest_name, quest_resource);
	
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Begin Quest"
	event_category = "RPG"
	event_sorting_index = 60



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "begin_quest"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"quest"		: {"property": "quest_name", 	"default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Begin Quest')
	add_body_edit('quest_name', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Quest Name'})

#endregion
