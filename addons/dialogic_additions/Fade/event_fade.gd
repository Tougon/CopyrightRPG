@tool
extends DialogicEvent
class_name DialogicFadeEvent

# Define properties of the event here
var fade_in := false;
var pre_delay := 0.0;
var post_delay := 0.0;
var instant := false;

func _execute() -> void:
	await dialogic.get_tree().create_timer(pre_delay).timeout
	
	if instant : 
		EventManager.overworld_cutscene_fade_instant.emit(fade_in);
		await EventManager.overworld_cutscene_fade_completed;
	else :
		EventManager.overworld_cutscene_fade_start.emit(fade_in);
		await EventManager.overworld_cutscene_fade_completed;
	
	await dialogic.get_tree().create_timer(post_delay).timeout
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Fade"
	event_category = "RPG"
	event_sorting_index = 10
	set_default_color('Color3')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "fade"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"in"		: {"property": "fade_in", 	"default": false},
		"pre"		: {"property": "pre_delay", 	"default": 0.0},
		"post"		: {"property": "post_delay", 	"default": 0.0},
		"inst"		: {"property": "instant", 	"default": false},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Fade')
	add_body_edit('fade_in', ValueType.BOOL, {
			'left_text'		: 'Fade In'})
	add_body_edit('pre_delay', ValueType.NUMBER, {
			'left_text'		: 'Pre Delay'})
	add_body_edit('post_delay', ValueType.NUMBER, {
			'left_text'		: 'Post Delay'})
	add_body_edit('instant', ValueType.BOOL, {
			'left_text'		: 'Instant'})

#endregion
