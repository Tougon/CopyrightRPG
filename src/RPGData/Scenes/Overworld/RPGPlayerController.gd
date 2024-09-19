extends CharacterBody2D
class_name RPGPlayerController

@export var speed : float = 250.0;
@export_range(1,10) var run_multiplier : float = 1.5;
@export_range(0.1, 1) var skid_duration : float = 0.25;

var movement_bounds : float = 0.5;
var prev_direction : Vector2;
var can_move : bool = true;

#TODO: Modify how the sprites work entirely.

func _ready():
	EventManager.on_battle_queue.connect(_on_overworld_battle_queued);
	EventManager.on_battle_dequeue.connect(_on_overworld_battle_dequeued);
	
	UIManager.on_menu_opened.connect(_on_menu_opened);
	UIManager.on_all_menus_closed.connect(_on_all_menus_closed);

func _process(_delta):
	if !can_move : return;
	
	# Handle pause input
	if Input.is_action_just_pressed("pause"):
		UIManager.open_menu_name("overworld_menu_main");
		return;
	
	# Handle movement
	var direction = _get_movement_vector();
	move(direction);
	
	# Debug
	$Sprite2D2.position = direction * 125
	if direction.length() > 0.5 : 
		$Sprite2D2.rotation_degrees = rad_to_deg(direction.angle()) - 90;
	else : $Sprite2D2.rotation_degrees = 0;
	# End Debug
	
	if Input.is_action_just_pressed("interact") && can_move:
		print("Interact ping")


func _get_movement_vector() -> Vector2:
	var h = Input.get_axis("move_l","move_r");
	var v = Input.get_axis("move_u", "move_d");
	
	var angle = rad_to_deg(Vector2(h, v).angle());
	
	h = h/abs(h) if abs(h) >= movement_bounds else 0;
	v = v/abs(v) if abs(v) >= movement_bounds else 0;
	
	var direction = Vector2(h, v).normalized();
	return direction;


func move(direction : Vector2):
	velocity = direction * speed;
	if Input.is_action_pressed("run") : velocity *= run_multiplier;
	var orig_pos = position;
	
	move_and_slide();
	
	var delta_pos = position - orig_pos;
	
	if delta_pos.length() > 0 : 
		EventManager.on_overworld_player_moved.emit(direction, velocity);
	
	if Input.is_action_just_released("run") || (Input.is_action_pressed("run") && prev_direction != direction && prev_direction.length_squared() > 0):
		var angle_dif = abs(rad_to_deg(prev_direction.angle_to(direction)))
		# We have to use 91 here due to bizarre rounding errors
		if angle_dif == 0 || angle_dif > 91 : 
			skid(prev_direction * speed * run_multiplier, prev_direction * speed);
	
	if prev_direction != direction: prev_direction = direction;


func skid(initial : Vector2, final : Vector2):
	var direction = initial.normalized();
	var orig_velocity = initial;
	var time = 0;
	can_move = false;
	
	while (time < skid_duration && skid_duration > 0):
		await get_tree().process_frame;
		velocity = lerp(orig_velocity, final, time / skid_duration);
		EventManager.on_overworld_player_moved.emit(direction, velocity);
		move_and_slide();
		time += get_process_delta_time();
	
	prev_direction = _get_movement_vector();
	can_move = true;


func _on_overworld_battle_queued(encounter : Encounter):
	set_process(false);


func _on_overworld_battle_dequeued():
	set_process(true);


func _on_menu_opened(menu : MenuPanel):
	set_process(false);


func _on_all_menus_closed():
	if BattleManager.is_battle_active == false:
		await get_tree().process_frame;
		await get_tree().process_frame;
		set_process(true);


func _exit_tree():
	if EventManager != null:
		EventManager.on_battle_queue.disconnect(_on_overworld_battle_queued);
		EventManager.on_battle_dequeue.disconnect(_on_overworld_battle_dequeued);
	
	if UIManager != null:
		UIManager.on_menu_opened.connect(_on_menu_opened);
		UIManager.on_all_menus_closed.connect(_on_all_menus_closed);
