extends Node

# Class that defines constant or important variables for the overworld
const FLOOR_TRANSITION_TIME : float = 0.45;
const ALLOW_CAMERA_LOCK : bool = false;

# Runtime variables
var player_controller : RPGPlayerController;
var game_camera : PhantomCamera2D;
var free_camera : PhantomCamera2D;

var encounter_wait_time : float;
var encounter_time : float;

# Called when the node enters the scene tree for the first time.
func _ready() :
	pass


func get_player_screen_position() -> Vector2:
	var screen = get_viewport().get_visible_rect().size;
	var origin = Vector2(player_controller.player_fade_offset.get_screen_transform().origin.x / screen.x, player_controller.player_fade_offset.get_screen_transform().origin.y / screen.y)
	
	return origin;
