@tool
extends DialogicEvent
class_name DialogicPlayCharacterAnimationEvent

var object_id := "";
var animation_name := "";

func _execute() -> void:
	var obj = CutsceneObjectManager.get_object(object_id);
	
	if obj != null:
		var character = obj as RPGCharacter;
		
		if character != null : 
			match (animation_name.to_lower()):
				"idle":
					character.set_state(RPGCharacter.AnimationState.IDLE);
				"walk":
					character.set_state(RPGCharacter.AnimationState.WALK);
				"run":
					character.set_state(RPGCharacter.AnimationState.RUN);
				_:
					character.play_one_shot(animation_name.to_lower())
	
	finish()


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Play Character Animation"
	event_category = "RPG"
	set_default_color('Color2')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "play_character_animation"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"id"		: {"property": "object_id", 	"default": ""},
		"anim_name"		: {"property": "animation_name", 	"default": ""},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Play Object Animation')
	add_body_edit('object_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Object ID'})
	add_body_edit('animation_name', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Animation Name'})

#endregion
