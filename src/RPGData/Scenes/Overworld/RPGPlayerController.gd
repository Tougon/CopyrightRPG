extends CharacterBody2D
class_name RPGPlayerController

@export var speed : float = 250.0;
var movement_bounds : float = 0.5;
#TODO: Modify how the sprites work entirely.

func _ready():
	EventManager.on_battle_queue.connect(_on_overworld_battle_queued);
	EventManager.on_battle_dequeue.connect(_on_overworld_battle_dequeued);
	
	UIManager.on_menu_opened.connect(_on_menu_opened);
	UIManager.on_all_menus_closed.connect(_on_all_menus_closed);

func _process(_delta):
	# Handle pause input
	if Input.is_action_just_pressed("pause"):
		UIManager.open_menu_name("overworld_menu_main");
		return;
	
	# Handle movement
	var h = Input.get_axis("move_l","move_r");
	var v = Input.get_axis("move_u", "move_d");
	
	var angle = rad_to_deg(Vector2(h, v).angle());
	
	h = h/abs(h) if abs(h) >= movement_bounds else 0;
	v = v/abs(v) if abs(v) >= movement_bounds else 0;
	
	var direction = Vector2(h, v).normalized();
	move(direction);
	
	# Debug
	$Sprite2D2.position = direction * 125
	if direction.length() > 0.5 : 
		$Sprite2D2.rotation_degrees = rad_to_deg(direction.angle()) - 90;
	else : $Sprite2D2.rotation_degrees = 0;
	# End Debug


func move(direction : Vector2):
	velocity = direction * speed;
	var orig_pos = position;
	
	move_and_slide();
	
	var delta_pos = position - orig_pos;
	
	if delta_pos.length() > 0 : 
		EventManager.on_overworld_player_moved.emit(direction, velocity);


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
