extends CharacterBody2D
class_name RPGPlayerController

@export var speed : float = 250.0;
@export_range(1,10) var run_multiplier : float = 1.5;
@export_range(0.1, 1) var skid_duration : float = 0.25;

const COLLISION_DETECTION_RANGE : float  = 80.0;

var direction_facing : Vector2 = Vector2(0, 1);

var _movement_bounds : float = 0.5;
var _prev_direction : Vector2;
var _will_process : bool = true;
var _can_move : bool = true;
var _in_dialogue : bool = false;

@onready var player_fade_offset: Node2D = $FadeOffset
@onready var _player_visual: RPGCharacter = $RPGCharacter
var _physics_body_trans_last: Transform2D
var _physics_body_trans_current: Transform2D


func _ready():
	EventManager.on_battle_queue.connect(_on_overworld_battle_queued);
	EventManager.on_battle_dequeue.connect(_on_overworld_battle_dequeued);
	
	UIManager.on_menu_opened.connect(_on_menu_opened);
	UIManager.on_all_menus_closed.connect(_on_all_menus_closed);
	
	Dialogic.timeline_started.connect(_on_dialogue_begin);
	Dialogic.timeline_ended.connect(_on_dialogue_end);


func _process(_delta: float) -> void:	
	_player_visual.global_position = _physics_body_trans_last.interpolate_with(
		_physics_body_trans_current,
		Engine.get_physics_interpolation_fraction()
	).origin
	

func _physics_process(_delta):
	_physics_body_trans_last = _physics_body_trans_current
	_physics_body_trans_current = global_transform
	
	if !_can_move || _in_dialogue || !_will_process : return;
	
	# Handle pause input
	if Input.is_action_just_pressed("pause"):
		UIManager.open_menu_name("overworld_menu_main");
		return;
	
	# Handle movement
	var direction = _get_movement_vector();
	move(direction, _delta);
	
	# Debug
	# TODO: Fix so that diagonals work properly. 1,1 is correct here ONLY
	$"Direction Root".position = (direction_facing) * COLLISION_DETECTION_RANGE;
	if direction_facing.length() > 0.5 : 
		$"Direction Root".rotation_degrees = rad_to_deg(direction_facing.angle()) - 90;
	else : $"Direction Root".rotation_degrees = 0;
	# End Debug
	
	if Input.is_action_just_pressed("interact") && _can_move:
		if $"Direction Root/Sight".closest_interactable != null :
			$"Direction Root/Sight".closest_interactable.interact();


func _get_movement_vector() -> Vector2:
	var h = Input.get_axis("move_l","move_r");
	var v = Input.get_axis("move_u", "move_d");
	
	var angle = rad_to_deg(Vector2(h, v).angle());
	
	h = h/abs(h) if abs(h) >= _movement_bounds else 0;
	v = v/abs(v) if abs(v) >= _movement_bounds else 0;
	
	var direction = Vector2(h, v).normalized();
	return direction;


func move(direction : Vector2, delta : float):
	velocity = direction * speed;
	if Input.is_action_pressed("run") : velocity *= run_multiplier;
	var orig_pos = position;
	
	move_and_slide();
	
	var delta_pos = position - orig_pos;
	
	if delta_pos.length() > 0 && !_in_dialogue: 
		EventManager.on_overworld_player_moved.emit(direction, velocity, delta);
	
	if direction.length_squared() != 0:
		direction_facing = direction;
	
	if Input.is_action_just_released("run") || (Input.is_action_pressed("run") && _prev_direction != direction && _prev_direction.length_squared() > 0):
		var angle_dif = abs(rad_to_deg(_prev_direction.angle_to(direction)))
		# We have to use 91 here due to bizarre rounding errors
		if angle_dif == 0 || angle_dif > 91 : 
			skid(_prev_direction * speed * run_multiplier, _prev_direction * speed);
	
	if _prev_direction != direction: 
		_prev_direction = direction;
		
	# Animation update if not sliding
	if _can_move : 
		update_locomotion_animation(direction, delta_pos.length_squared());


func update_locomotion_animation(direction : Vector2, delta : float):
	_player_visual.set_direction(direction);
	
	if Input.is_action_pressed("run") && delta > 0 : _player_visual.set_state(RPGCharacter.AnimationState.RUN);
	elif direction.length_squared() > 0 && delta > 0 : _player_visual.set_state(RPGCharacter.AnimationState.WALK);
	else : _player_visual.set_state(RPGCharacter.AnimationState.IDLE);


func skid(initial : Vector2, final : Vector2):
	var direction = initial.normalized();
	var orig_velocity = initial;
	var time = 0;
	_can_move = false;
	
	_player_visual.play_one_shot("slide");
	
	while (time < skid_duration && skid_duration > 0 && !_in_dialogue):
		velocity = lerp(orig_velocity, final, time / skid_duration);
		move_and_slide();
		if !_in_dialogue: EventManager.on_overworld_player_moved.emit(direction, velocity, get_physics_process_delta_time());
		time += get_physics_process_delta_time();
		await get_tree().physics_frame;
	
	_prev_direction = _get_movement_vector();
	_can_move = true;
	update_locomotion_animation(_prev_direction, _prev_direction.length());


func _on_overworld_battle_queued(encounter : Encounter):
	_will_process = false;
	_player_visual.set_process(false);
	#set_process(false);


func _on_overworld_battle_dequeued():
	_will_process = true;
	_player_visual.set_process(true);
	#set_process(true);


func _on_menu_opened(menu : MenuPanel):
	velocity = Vector2.ZERO;
	_will_process = false;
	_player_visual.set_process(false);
	#set_process(false);


func _on_dialogue_begin():
	_in_dialogue = true;


func _on_dialogue_end():
	_in_dialogue = false;


func _on_all_menus_closed():
	if BattleManager.is_battle_active == false:
		await get_tree().process_frame;
		await get_tree().process_frame;
		_will_process = true
		_player_visual.set_process(true);
		#set_process(true);


func _exit_tree():
	if EventManager != null:
		EventManager.on_battle_queue.disconnect(_on_overworld_battle_queued);
		EventManager.on_battle_dequeue.disconnect(_on_overworld_battle_dequeued);
	
	if UIManager != null:
		UIManager.on_menu_opened.disconnect(_on_menu_opened);
		UIManager.on_all_menus_closed.disconnect(_on_all_menus_closed);
	
	Dialogic.timeline_started.disconnect(_on_dialogue_begin);
	Dialogic.timeline_ended.disconnect(_on_dialogue_end);
