@tool
extends DialogicEvent
class_name DialogicPlayCharacterAnimationEvent

var object_id := "";
var animation_name := "";
var change_direction := false;
var direction : Vector2;

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
			
			if change_direction :
				character.set_direction(direction);
	
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
		"change_dir"		: {"property": "change_direction", 	"default": false},
		"dir"		: {"property": "direction", 	"default": Vector2.ZERO},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Play Character Animation')
	add_body_edit('object_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Object ID'})
	add_body_edit('animation_name', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Animation Name'})
	add_body_edit('change_direction', ValueType.BOOL, {
			'left_text'		: 'Change Direction'})
	add_body_edit('direction', ValueType.VECTOR2, {
			'left_text'		: 'Direction'})

#endregion
