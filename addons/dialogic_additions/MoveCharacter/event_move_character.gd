@tool
extends DialogicEvent
class_name DialogicMoveCharacterEvent

# Character to move
var object_id := "";
var move_duration : float = 1.0;
# Determines if event should wait until player reaches their destination
var await_destination := false;
var destination : Vector2;
# Determines if destination should be a relative or literal value
var relative := true;
# Object to move to
var destination_object_id := "";
# Determines if the Run animation should be used
var run_anim := false;

var _character : RPGCharacter;
var _tween_success := false;


func _execute() -> void:
	var obj = CutsceneObjectManager.get_object(object_id);
	
	if obj != null:
		var character = obj as RPGCharacter;
		
		if character != null : 
			_character = character;
			var dir = Vector2.ZERO;
			
			# Create tween for later
			var tween : Tween;
			tween = character.get_tree().create_tween();
			tween.set_parallel(true);
			
			# Check if there is a destination object
			var dest_obj = CutsceneObjectManager.get_object(destination_object_id);
			
			if dest_obj != null :
				var pos = dest_obj.global_position;
				var property = tween.tween_property(character, "position", pos, move_duration);
				property.set_trans(Tween.TRANS_LINEAR);
				property.set_ease(Tween.EASE_IN_OUT);
				
				dir = pos.normalized();
			
			else :
				var pos = destination;
				var property = tween.tween_property(character, "position", pos, move_duration);
				property.set_trans(Tween.TRANS_LINEAR);
				property.set_ease(Tween.EASE_IN_OUT);
				
				if relative :
					property.as_relative();
					dir = pos.normalized();
				else :
					dir = (pos - character.position).normalized();
			
			# Handle animation and direction
			character.set_direction(_convert_angle(dir));
			
			if run_anim : character.set_state(RPGCharacter.AnimationState.RUN);
			else : character.set_state(RPGCharacter.AnimationState.WALK);
			
			# Tween callbacks
			tween.tween_callback(_on_tween_complete).set_delay(move_duration);
			_tween_success = true;
	
	if !_tween_success || !await_destination: finish()


func _convert_angle(direction : Vector2) -> Vector2:
	var angle = rad_to_deg(direction.angle())
	
	if angle >= -30 && angle <= 30 : return Vector2.RIGHT;
	elif angle >= 150 || angle <= -150 : return Vector2.LEFT;
	elif angle < 0 : return Vector2.DOWN;
	
	return Vector2.UP;


func _on_tween_complete():
	_character.set_state(RPGCharacter.AnimationState.IDLE);
	
	if await_destination: finish();


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Move Character"
	event_category = "RPG"
	set_default_color('Color2')



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "move_character"

func get_shortcode_parameters() -> Dictionary:
	return {
		"id"		: {"property": "object_id", 	"default": ""},
		"duration"		: {"property": "move_duration", 	"default": 1.0},
		"await"		: {"property": "await_destination", 	"default": false},
		"dest"		: {"property": "destination", 	"default": Vector2.ZERO},
		"rel"		: {"property": "relative", 	"default": true},
		"dest_id"		: {"property": "destination_object_id", 	"default": ""},
		"run"		: {"property": "run_anim", 	"default": false},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	add_header_label('Move Character')
	add_body_edit('object_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Object ID'})
	add_body_edit('move_duration', ValueType.NUMBER, {
			'left_text'		: 'Move Duration'})
	add_body_edit('await_destination', ValueType.BOOL, {
			'left_text'		: 'Await Destination'})
	add_body_edit('destination', ValueType.VECTOR2, {
			'left_text'		: 'Destination'})
	add_body_edit('relative', ValueType.BOOL, {
			'left_text'		: 'Relative'})
	add_body_edit('destination_object_id', ValueType.SINGLELINE_TEXT, {
			'left_text'		: 'Destination Object ID'})
	add_body_edit('run_anim', ValueType.BOOL, {
			'left_text'		: 'Running'})

#endregion
