@tool
extends DialogicEvent
class_name DialogicChangeLevelEvent

# Define properties of the event here
var set_level := false;
var level_delta := 1.0;

func _execute() -> void:
	var amt = roundi(level_delta);
	
	for i in DataManager.party_data.size():
		if set_level : 
			if amt > 0 && amt <= BattleManager.level_cap :
				DataManager.party_data[i].level = amt;
				DataManager.party_data[i].exp = 0;
		else :
			DataManager.party_data[i].level = clamp(DataManager.party_data[i].level + amt, 1, BattleManager.level_cap);
			DataManager.party_data[i].exp = 0;
	
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Change Level"
	event_category = "RPG"
	event_sorting_index = 200
	set_default_color('Color4')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "change_level"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		#"my_parameter"		: {"property": "property", "default": "Default"},
		"set_lvl"		: {"property": "set_level", 	"default": false},
		"delta"		: {"property": "level_delta", 	"default": 1.0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Change Level')
	add_body_edit('set_level', ValueType.BOOL, {
			'left_text'		: 'Set Level'})
	add_body_edit('level_delta', ValueType.NUMBER, {
			'left_text'		: 'Level Delta'})

#endregion
