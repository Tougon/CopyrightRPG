@tool
extends DialogicEvent
class_name DialogicModifyPlayerStateEvent

# Define properties of the event here
var affect_all : = false;
var affected_player_id := 0;

var modify_hp := true;
var hp_amount := 0;
var use_hp_percent := false;
var hp_percent := 1.0;

var modify_mp := true;
var mp_amount := 0;
var use_mp_percent := false;
var mp_percent := 1.0;

func _execute() -> void:
	
	if affect_all : 
		for id in DataManager.party_data.size() :
			_modify_status(id);
	else:
		_modify_status(affected_player_id)
	
	finish() 


func _modify_status(id : int):
	if id < DataManager.party_data.size() && id >= 0:
		var player_state = DataManager.party_data[id];
		var player = DataManager.entity_database.get_entity(player_state.id, true);
		
		if player != null :
			var max_hp = player.get_hp(player_state.level);
			var max_mp = player.get_mp(player_state.level);
			
			var hp_amt = hp_amount;
			var mp_amt = mp_amount;
			
			if use_hp_percent :
				hp_amt = roundi((max_hp as float) * hp_percent);
			
			if use_mp_percent :
				mp_amt = roundi((max_mp as float) * mp_percent);
			
			player_state.hp_value = clamp(hp_amt, 1, max_hp);
			player_state.mp_value = clamp(mp_amt, 0, max_mp);


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Modify Player State"
	set_default_color('Color1')
	event_category = "RPG"
	event_sorting_index = 60



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "modify_player_state"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"all_targets"		: {"property": "affect_all", 	"default": false},
		"targets"		: {"property": "affected_player_id", 	"default": 0},
		"hp"		: {"property": "modify_hp", 	"default": true},
		"hp_amt"		: {"property": "hp_amount", 	"default": 0},
		"hp_percent_check"		: {"property": "use_hp_percent", 	"default": false},
		"hp_percent_amt"		: {"property": "hp_percent", 	"default": 1.0},
		"mp"		: {"property": "modify_mp", 	"default": true},
		"mp_amt"		: {"property": "mp_amount", 	"default": 0},
		"mp_percent_check"		: {"property": "use_mp_percent", 	"default": false},
		"mp_percent_amt"		: {"property": "mp_percent", 	"default": 1.0},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Modify Player State')
	
	add_body_edit('affect_all', ValueType.BOOL, {
			'left_text'		: 'Affect All'})
	
	add_body_edit('affected_player_id', ValueType.NUMBER, {
			'left_text'		: 'Affected Player ID'})
	
	add_body_edit('modify_hp', ValueType.BOOL, {
			'left_text'		: 'Modify HP'})
	add_body_edit('use_hp_percent', ValueType.BOOL, {
			'left_text'		: 'Use HP Percent'})
	add_body_edit('hp_percent', ValueType.NUMBER, {
			'left_text'		: 'HP Percent'})
	add_body_edit('hp_amount', ValueType.NUMBER, {
			'left_text'		: 'HP Amount'})
	
	add_body_edit('modify_mp', ValueType.BOOL, {
			'left_text'		: 'Modify MP'})
	add_body_edit('use_mp_percent', ValueType.BOOL, {
			'left_text'		: 'Use MP Percent'})
	add_body_edit('mp_percent', ValueType.NUMBER, {
			'left_text'		: 'MP Percent'})
	add_body_edit('mp_amount', ValueType.NUMBER, {
			'left_text'		: 'MP Amount'})

#endregion
