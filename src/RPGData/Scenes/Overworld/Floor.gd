extends Node2D
class_name Floor

@export_range(-9,9) var floor_index : int = 0;

@onready var tile_map_floor : TileMapLayer = $"TileMapFloor";
@onready var tile_map_wall : TileMapLayer = $"TileMapWalls";
@export var tile_map_aux : Array[TileMap];

@onready var environment : Node2D = $Environment;


# Active refers specifically to collision
func set_floor_active(active : bool):
	tile_map_floor.collision_enabled = active;
	tile_map_wall.collision_enabled = active;
	
	if active : 
		process_mode = ProcessMode.PROCESS_MODE_INHERIT;
	else :
		process_mode = ProcessMode.PROCESS_MODE_DISABLED;


func set_floor_visible(visible : bool, tween : bool = true):
	if !tween :
		if visible : 
			modulate = Color.WHITE;
		else : 
			modulate = Color.TRANSPARENT;
	else :
		var mod_tween = get_tree().create_tween();
		
		if visible :
			mod_tween.tween_property(self, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
		else :
			mod_tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);


func put_player_on_floor(player : Node2D):
	player.reparent(environment);


func put_camera_on_floor(game_camera : PhantomCamera2D, free_camera : PhantomCamera2D):
	game_camera.limit_target = game_camera.get_path_to(tile_map_wall)
	free_camera.limit_target = free_camera.get_path_to(tile_map_wall)
