extends Node2D
class_name RPGCharacter;

enum AnimationState { IDLE, WALK, RUN };

@onready var sprite : Sprite2D = $Sprite2D;

@export_subgroup("Character")
@export var character : RPGCharacterData;

var _current_anim : RPGCharacterAnimation;
var _current_state : AnimationState;
var _previous_direction : Vector2 = Vector2(0, 0);
var _direction : Vector2 = Vector2(0, 1);

var _current_frame : int;
var _current_frame_time : float;
var _current_walk_frame : int = 0;
var _current_run_frame : int = 0;


func _ready():
	set_state(AnimationState.IDLE);
	set_direction(_direction);


# Strictly handles frame switching
func _process(delta: float):
	_current_frame_time += delta;
	
	if _current_anim != null && _current_frame_time >= _current_anim.sequence[_current_frame].frame_time :
		_current_frame += 1;
		_current_frame_time = 0;
		
		_update_sprite();


func _update_sprite():
	if _current_anim == null : return;
	
	if _current_frame >= _current_anim.sequence.size():
		_current_frame = 0;
	
	sprite.texture = _current_anim.sequence[_current_frame].frame_sprite;


func set_direction(new_direction : Vector2):
	if new_direction.length_squared() == 0 : return;
	
	_previous_direction = _direction;
	_direction = new_direction;


func set_state(new_state : AnimationState):
	_current_state = new_state;
	
	var anim_group : RPGCharacterAnimationGroup;
	
	match (_current_state):
		AnimationState.IDLE:
			anim_group = character.idle;
		AnimationState.WALK:
			anim_group = character.walk;
		AnimationState.RUN:
			anim_group = character.run;
	
	if anim_group == null : return;
	
	_current_anim = anim_group.get_anim(_direction, _previous_direction);
	
	_update_sprite();
