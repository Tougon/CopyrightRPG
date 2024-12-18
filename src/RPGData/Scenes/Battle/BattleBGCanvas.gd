extends CanvasLayer
class_name BGVideoCanvas

enum LoadType { ENTITY, ATTACK }

@export var video_main : LoopingVideoPlayer;
@export var video_ghost : LoopingVideoPlayer;
@export var solid_layer : ColorRect;
@export var static_layer : ColorRect;

var _video_main : VideoStream;
var _material_main : Material;
var _material_ghost : Material;

var _attack_to_video_map : Dictionary
var _attack_to_shader_map : Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_static(true);
	
	EventManager.on_battle_begin.connect(_on_battle_begin);


func _on_battle_begin(params : BattleParams):
	# TODO: See if we need to remove these from memory or something
	_video_main = null;
	_material_main = null;
	_material_ghost = null;
	_attack_to_video_map.clear();
	_attack_to_shader_map.clear();
	
	for enemy_index in params.enemies.size():
		var enemy = params.enemies[enemy_index];
		if enemy_index == 0 : 
			load_video_full(enemy.entity_video, enemy.entity_video_material_primary, enemy.entity_video_material_secondary, LoadType.ENTITY, enemy);


func load_video_full(vid_path : String, mat1_path : String, mat2_path : String, load_type : LoadType, aux : Resource):
	var vid = load_video(vid_path);
	var mat1 = load_material(mat1_path);
	var mat2 = load_material(mat2_path);
	
	if load_type == LoadType.ENTITY:
		_video_main = vid;
		_material_main = mat1;
		_material_ghost = mat2;
		
		video_main.stream = _video_main;
		video_main.material = mat1;
		video_ghost.stream = _video_main;
		video_ghost.material = mat2;
		
		_set_static(false);
		
		video_main.play_video();
		video_ghost.play_video();


func load_video(path : String) -> VideoStream:
	if ResourceLoader.exists(path, "VideoStream"):
		var video = ResourceLoader.load(path, "VideoStream") as VideoStream;
		return video;
	return null;


func load_material(path : String) -> Material:
	if ResourceLoader.exists(path, "Material"):
		var mat = ResourceLoader.load(path, "Material") as Material;
		return mat;
	return null;


func _set_static(active : bool) :
	static_layer.visible = active;
	solid_layer.visible = !active;
	video_main.visible = !active;
	video_ghost.visible = !active;


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_begin.disconnect(_on_battle_begin);
