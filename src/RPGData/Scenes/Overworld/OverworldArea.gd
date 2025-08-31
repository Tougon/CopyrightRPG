extends Node2D
class_name OverworldArea

@export var area_name_key : String;
var _floors : Dictionary;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var all_floors = self.get_children();
	
	for floor in all_floors:
		var floor_data = floor as Floor;
		if floor_data != null :
			floor_data.visible = true;
			floor_data.set_floor_visible(false, false);
			floor_data.set_floor_active(false);
			
			if !_floors.has(floor_data.floor_index):
				_floors[floor_data.floor_index] = floor_data;


# Active refers specifically to collision
func set_area_active(active : bool):
	if active : 
		set_process(true);
		process_mode = ProcessMode.PROCESS_MODE_INHERIT;
		physics_interpolation_mode = PhysicsInterpolationMode.PHYSICS_INTERPOLATION_MODE_INHERIT;
	else :
		set_process(false);
		process_mode = ProcessMode.PROCESS_MODE_DISABLED;
		physics_interpolation_mode = PhysicsInterpolationMode.PHYSICS_INTERPOLATION_MODE_OFF;


func has_floor(floor : int) -> bool:
	return _floors.has(floor);


func set_floor_active(floor : int, active : bool):
	if _floors.has(floor) :
		_floors[floor].set_floor_active(active);


func set_floor_visible(floor : int, visible : bool, tween : bool = true):
	if _floors.has(floor) :
		_floors[floor].set_floor_visible(visible, tween);


func put_player_on_floor(floor : int, player : Node2D):
	if _floors.has(floor) :
		_floors[floor].put_player_on_floor(player);


func put_camera_on_floor(floor : int, game_camera : PhantomCamera2D, free_camera : PhantomCamera2D):
	if _floors.has(floor) :
		_floors[floor].put_camera_on_floor(game_camera, free_camera);
