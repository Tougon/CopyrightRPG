extends Node2D
class_name RPGOverworldFollower

# The node we should follow
@export var target : Node2D;
@export var max_positions : int = 25;

@onready var _player_visual: RPGCharacter = $RPGCharacter

var _target_positions : Array[Vector2];
var _prev_target_position : Vector2;
var _direction : Vector2;
var _initialized;

var _physics_body_trans_last: Transform2D
var _physics_body_trans_current: Transform2D

func _init() :
	if target != null : _initialize_position();
	
	
func _process(_delta: float) -> void:	
	_player_visual.global_position = _physics_body_trans_last.interpolate_with(
		_physics_body_trans_current,
		Engine.get_physics_interpolation_fraction()
	).origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) :
	_physics_body_trans_last = _physics_body_trans_current
	_physics_body_trans_current = global_transform
	
	if target != null :
		# Initialize if we haven't already
		if !_initialized : _initialize_position();
		
		if _target_positions.size() > 0 && _target_positions.size() > max_positions:
			var _direction_unnorm = (_target_positions[0] - position);
			_direction = _direction_unnorm.normalized();
			update_locomotion_animation(_direction, _direction_unnorm.length_squared());
			
			position = _target_positions[0];
			_target_positions.remove_at(0);
		else : update_locomotion_animation(_direction, 0);
		
		if target.position.distance_to(_prev_target_position) > 0:
			_target_positions.append(target.position);
			_prev_target_position = target.position;


func _initialize_position():
	position = target.position;
	_initialized = true;


func update_locomotion_animation(direction : Vector2, delta : float):
	_player_visual.set_direction(direction);
	
	# TODO: Add support for running
	#if Input.is_action_pressed("run") && delta > 0 : _player_visual.set_state(RPGCharacter.AnimationState.RUN);
	if direction.length_squared() > 0 && delta > 0 : _player_visual.set_state(RPGCharacter.AnimationState.WALK);
	else : _player_visual.set_state(RPGCharacter.AnimationState.IDLE);
