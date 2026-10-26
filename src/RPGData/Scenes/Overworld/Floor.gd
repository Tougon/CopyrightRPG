extends Node2D
class_name Floor

@export_range(-9,9) var floor_index : int = 0;

@onready var tile_map_floor : TileMapLayer = $"TileMapFloor";
@onready var tile_map_wall : TileMapLayer = $"TileMapWalls";
@export var tile_map_aux : Array[TileMap];

@onready var environment : Node2D = $Environment;
@onready var environment_visuals : Node2D = $Environment/Visuals;

@onready var lighting : Node2D = $Environment/Visuals/Lighting;

@export var use_floor_as_bounds : bool = true;

var _override_step_sound : String = "";


func _ready() -> void:
	EventManager.play_impact_sfx.connect(_play_impact_sfx);


# Active refers specifically to collision
func set_floor_active(active : bool):
	tile_map_floor.collision_enabled = active;
	tile_map_wall.collision_enabled = active;
	
	if active : 
		set_process(true);
		process_mode = ProcessMode.PROCESS_MODE_INHERIT;
		physics_interpolation_mode = PhysicsInterpolationMode.PHYSICS_INTERPOLATION_MODE_INHERIT;
		EventManager.on_overworld_floor_active.emit(self);
		
		if lighting != null :
			lighting.reparent(environment);
			lighting.reparent(environment_visuals);
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
	if use_floor_as_bounds && OverworldManager.ALLOW_CAMERA_LOCK : 
		game_camera.limit_target = game_camera.get_path_to(tile_map_wall)
		free_camera.limit_target = free_camera.get_path_to(tile_map_wall)


func get_floor_bounds() -> Rect2:
	var tile_map_bounds = Vector2(tile_map_floor.get_used_rect().size) * Vector2(tile_map_floor.tile_set.tile_size) * tile_map_floor.get_scale()
	var tile_map_position : Vector2 = tile_map_floor.global_position + Vector2(tile_map_floor.get_used_rect().position) * Vector2(tile_map_floor.tile_set.tile_size) * tile_map_floor.get_scale();
	
	var bounds = Rect2(tile_map_position, tile_map_bounds);
	return bounds;


func is_on_tile(pos : Vector2) -> bool:
	var map_pos = tile_map_floor.local_to_map(tile_map_floor.to_local(pos));
	var tile_data = tile_map_floor.get_cell_tile_data(map_pos);
	
	return tile_data != null;


func _play_impact_sfx(pos : Vector2) :
	if (process_mode == ProcessMode.PROCESS_MODE_DISABLED) : return;
	
	var map_pos = tile_map_floor.local_to_map(tile_map_floor.to_local(pos));
	var tile_data = tile_map_floor.get_cell_tile_data(map_pos);
	
	if (tile_data != null) :
		var tile_sfx_id = tile_data.get_custom_data("SFX ID") as int;
		var tile_sfx = AudioManager.floor_sfx_map.get_floor_sfx(tile_sfx_id);
		AudioManager.play_sfx(tile_sfx, 0.2);


func _exit_tree():
	if EventManager != null :
		EventManager.play_impact_sfx.disconnect(_play_impact_sfx);
