extends Node2D
class_name RPGOverworldFollower

enum MovementType { Direct, Indirect }

# The node we should follow
@export var target : Node2D;
@export var movement_type : MovementType;
@export var max_positions : int = 25;
@export var target_radius : float = 64;
@export var speed : float = 200;

@onready var _player_visual: RPGCharacter = $RPGCharacter

var _target_positions : Array[Vector2];
var _prev_target_position : Vector2;
var _direction : Vector2;
var _initialized;
var _in_dialogue : bool = false;
var _reparenting : bool = false;

var _physics_body_trans_last: Transform2D
var _physics_body_trans_current: Transform2D

# Indirect Vars
var _prev_target_direction : Vector2;
var _ahead_of_target_idle : bool = false;
var _ahead_of_target_motion : bool = false;


func _ready() :
	if target != null : 
		_initialize_position();
		
	match movement_type :
		MovementType.Direct:
			$Collision/ShapeCast2D.enabled = false;
	
	Dialogic.timeline_started.connect(_on_dialogue_begin);
	Dialogic.timeline_ended.connect(_on_dialogue_end);
	
	EventManager.on_overworld_player_reparented.connect(_on_player_reparented);


func _process(_delta: float) -> void:	
	_player_visual.global_position = _physics_body_trans_last.interpolate_with(
		_physics_body_trans_current,
		Engine.get_physics_interpolation_fraction()
	).origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) :
	_physics_body_trans_last = _physics_body_trans_current
	_physics_body_trans_current = global_transform;
	
	match movement_type :
		MovementType.Direct:
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
		
		MovementType.Indirect:
			if target != null :
				# Initialize if we haven't already
				if !_initialized : _initialize_position();
				
				# If follower is too close to the target, do nothing
				#if target.position.distance_to(position) < target_radius * 1.5 :
				#	_prev_target_position = target.position;
				#	return;
				var dif = target.position - _prev_target_position;
				var dir = dif.normalized();
				var angle = rad_to_deg(dir.angle())
				
				# Target is in motion
				if abs(target.position.distance_to(_prev_target_position)) > 0.1:
					_prev_target_direction = dir;
					$Collision/ShapeCast2D.rotation_degrees = angle - 90;
					
					if $Collision/ShapeCast2D.is_colliding() :
						var collider = $Collision/ShapeCast2D.get_collider(0);
						
						if collider is RPGPlayerController || collider.get_parent() is RPGOverworldFollower :
							_prev_target_position = target.position; 
							return;
						else :
							var new_dir : Vector2;
							
							# Diagonals allow you to clip
							if abs(dir.x) != 0 && abs(dir.y) != 0 :
								var normal = $Collision/ShapeCast2D.get_collision_normal(0);
								
								if abs(normal.x) > 0:
									dir.x = 0;
								if abs(normal.y) > 0 :
									dir.y = 0;
							else :
								if dir.x != 0 :
									if target.position.y < position.y :
										new_dir.y = -abs(dir.x);
									else : 
										new_dir.y = abs(dir.x);
								
								if dir.y != 0 :
									if target.position.x < position.x :
										new_dir.x = -abs(dir.y);
									else : 
										new_dir.x = abs(dir.y);
							
							dir = new_dir;
							
							# Update angle
							#angle = rad_to_deg(dir.angle())
							#$Collision/ShapeCast2D.rotation_degrees = angle - 90;
							#if $Collision/ShapeCast2D.is_colliding() :
							#	dir = Vector2.ZERO;
					
					# If we are far enough ahead of the target, do nothing until the target catches up
					if (dir.y < 0 && position.y + target_radius * 1.5 < target.position.y) || (dir.y > 0 && position.y - target_radius * 1.5 > target.position.y) || (dir.x < 0 && position.x + target_radius * 1.5 < target.position.x) || (dir.x > 0 && position.x - target_radius * 1.5 > target.position.x):
						_ahead_of_target_motion = true;
					
					if _ahead_of_target_motion || _ahead_of_target_idle :
						if (dir.y < 0 && target.position.y + target_radius < position.y) || (dir.y > 0 && target.position.y - target_radius > position.y) || (dir.x < 0 && target.position.x + target_radius < position.x) || (dir.x > 0 && target.position.x - target_radius > position.x):
							_ahead_of_target_motion = false;
							_ahead_of_target_idle = false;
					
					if !_ahead_of_target_idle && !_ahead_of_target_motion:
						position += (dir * speed * get_physics_process_delta_time());
					
					_prev_target_position = target.position;
				else:
					if (_prev_target_direction.y < 0 && position.y < target.position.y) || (_prev_target_direction.y > 0 && position.y > target.position.y) || (_prev_target_direction.x < 0 && position.x < target.position.x) || (_prev_target_direction.x > 0 && position.x > target.position.x):
						_ahead_of_target_idle = true;
					_ahead_of_target_motion = false;
					_prev_target_position = target.position;


func _initialize_position():
	match movement_type :
		MovementType.Direct:
			position = target.position;
		MovementType.Indirect:
			var offset = _get_random_offset();
			position = target.position + offset;
			print("OFFSET: " + str(offset));
	
	if target != null : 
		_prev_target_position = target.position;
	
	_initialized = true;


func _get_random_offset() -> Vector2:
	var rand_x = randf_range(-1, 1);
	var rand_y = randf_range(-1, 1);
	var offset = Vector2(cos(rand_x) * target_radius, sin(rand_y) * target_radius);
	
	return offset;


func update_locomotion_animation(direction : Vector2, delta : float):
	_player_visual.set_direction(direction);
	
	# TODO: Add support for running
	#if Input.is_action_pressed("run") && delta > 0 : _player_visual.set_state(RPGCharacter.AnimationState.RUN);
	if direction.length_squared() > 0 && delta > 0 : _player_visual.set_state(RPGCharacter.AnimationState.WALK);
	else : _player_visual.set_state(RPGCharacter.AnimationState.IDLE);


func _on_dialogue_begin():
	_in_dialogue = true;


func _on_dialogue_end():
	_in_dialogue = false;
	
	# Force reset player position
	_player_visual.position = Vector2.ZERO;


func _on_player_reparented(parent : Node2D) :
	_reparenting = true;
	self.reparent(parent);


func _exit_tree():
	if _reparenting : 
		_reparenting = false;
	else :
		Dialogic.timeline_started.disconnect(_on_dialogue_begin);
		Dialogic.timeline_ended.disconnect(_on_dialogue_end);
		
		if EventManager != null :
			EventManager.on_overworld_player_reparented.disconnect(_on_player_reparented);
