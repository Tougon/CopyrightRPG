extends Node2D
class_name Floor

@export_range(-9,9) var floor_index : int = 0;

@onready var tile_map_floor : TileMapLayer = $"TileMapFloor";
@onready var tile_map_wall : TileMapLayer = $"TileMapWalls";
@export var tile_map_aux : Array[TileMap];

@onready var environment : Node2D = $Environment;
@onready var environment_visuals : Node2D = $Environment/Visuals;

@onready var lighting : Node2D = $Environment/Visuals/Lighting;


# Active refers specifically to collision
func set_floor_active(active : bool):
	tile_map_floor.collision_enabled = active;
	tile_map_wall.collision_enabled = active;
	
	if active : 
		set_process(true);
		process_mode = ProcessMode.PROCESS_MODE_INHERIT;
		physics_interpolation_mode = PhysicsInterpolationMode.PHYSICS_INTERPOLATION_MODE_INHERIT;
	else :
		set_process(false);
		process_mode = ProcessMode.PROCESS_MODE_DISABLED;
		physics_interpolation_mode = PhysicsInterpolationMode.PHYSICS_INTERPOLATION_MODE_OFF;
	
	if lighting != null : lighting.visible = active;


func set_floor_visible(visible : bool, tween : bool = true):
	if !tween :
		if visible : 
			tile_map_floor.modulate = Color.WHITE;
			tile_map_wall.modulate = Color.WHITE;
			environment_visuals.modulate = Color.WHITE;
		else : 
			tile_map_floor.modulate = Color.TRANSPARENT;
			tile_map_wall.modulate = Color.TRANSPARENT;
			environment_visuals.modulate = Color.TRANSPARENT;
	else :
		if get_tree() == null : return;
		
		var mod_tween = get_tree().create_tween();
		mod_tween.set_parallel(true);
		
		if visible :
			mod_tween.tween_property(tile_map_floor, "modulate", Color.WHITE, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
			mod_tween.tween_property(tile_map_wall, "modulate", Color.WHITE, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
			mod_tween.tween_property(environment_visuals, "modulate", Color.WHITE, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
		else :
			mod_tween.tween_property(tile_map_floor, "modulate", Color.TRANSPARENT, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
			mod_tween.tween_property(tile_map_wall, "modulate", Color.TRANSPARENT, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);
			mod_tween.tween_property(environment_visuals, "modulate", Color.TRANSPARENT, OverworldManager.FLOOR_TRANSITION_TIME).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT);


func put_player_on_floor(player : Node2D):
	player.reparent_player(environment);


func put_camera_on_floor(game_camera : PhantomCamera2D, free_camera : PhantomCamera2D):
	game_camera.limit_target = game_camera.get_path_to(tile_map_wall)
	free_camera.limit_target = free_camera.get_path_to(tile_map_wall)
