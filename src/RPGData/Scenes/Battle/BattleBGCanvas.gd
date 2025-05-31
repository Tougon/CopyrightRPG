extends CanvasLayer
class_name BGVideoCanvas

enum LoadType { ENTITY, ATTACK }

@export var video_layer : LoopingVideoPlayer;
# NOTE: Later, try replacing this with a better video decoder.
@export var attack_layer : LoopingVideoPlayer;
@export var color_layer : LoopingVideoPlayer;
@export var solid_layer : ColorRect;
@export var static_layer : ColorRect;
@export var effect_layer_list : Array[LoopingVideoPlayer];
@export var effect_layer_default_mat : Material;
@export var start_static : bool = true;
@export var test_attack_layer : bool = false;

# Cached video and material instances
var _video_main : VideoStream;
var _material_main : Material;
var _material_ghost : Material;

var _attack_to_video_map : Dictionary = {};
var _entity_to_color_mat_map : Dictionary = {};
var _attack_to_shader_map : Dictionary = {};

var _current_spell : Spell;
var _runtime_main : float;

var _is_attacking = false;
var _attack_time = 0;

# TODO: Async loading Probably

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.on_battle_begin.connect(_on_battle_begin);
	EventManager.set_player_bg.connect(_set_player_bg);
	EventManager.set_spell_bg.connect(_set_spell_bg);
	EventManager.set_effect_bg.connect(_set_effect_bg);
	EventManager.register_player.connect(_load_entity_spell_data);
	EventManager.register_enemy.connect(_load_entity_spell_data);
	
	if start_static : _set_static(true);
	else : 
		video_layer.play_video();
		color_layer.play_video();
		
		if test_attack_layer:
			attack_layer.visible = true;
			attack_layer.material.set_shader_parameter("use_manual_time", true);
			attack_layer.play_video();
			_is_attacking = true;


func _process(delta: float):
	if _is_attacking :
		_attack_time += delta;
		attack_layer.material.set_shader_parameter("manual_time", _attack_time)


func _on_battle_begin(params : BattleParams):
	# TODO: See if we need to remove these from memory or something
	_video_main = null;
	_material_main = null;
	_material_ghost = null;
	_attack_to_video_map.clear();
	_attack_to_shader_map.clear();
	_entity_to_color_mat_map.clear();
	
	for player_index in params.players.size():
		if params.players[player_index] != null :
			var player = params.players[player_index].override_entity;
			
			if !_entity_to_color_mat_map.has(player):
				var color = load_material(player.entity_thought_pattern_material);
				_entity_to_color_mat_map[player] = color;
	
	for enemy_index in params.enemies.size():
		var enemy = params.enemies[enemy_index];
		if enemy_index == 0 : 
			load_video_full(enemy.entity_video, enemy.entity_video_material, enemy.entity_thought_pattern_material, LoadType.ENTITY, enemy);
		
		if !_entity_to_color_mat_map.has(enemy):
			var color = load_material(enemy.entity_thought_pattern_material);
			_entity_to_color_mat_map[enemy] = color;


func _load_entity_spell_data(entity : EntityController):
	if entity is PlayerController:
		_load_spell_data(entity.attack_action);
		_load_spell_data(entity.defend_action);
	
	for move in entity.move_list:
		_load_spell_data(move);


func _load_spell_data(move : Spell):
	if move.spell_videos != null && !_attack_to_video_map.has(move) && move.spell_videos.size() > 0:
		
		_attack_to_video_map[move] = [];
		
		for video_path in move.spell_videos :
			var video = load_video(video_path);
			
			if video != null : 
				_attack_to_video_map[move].append(video);
	
	if move.spell_video_materials != null && !_attack_to_shader_map.has(move) && move.spell_video_materials.size() > 0:
		
		_attack_to_shader_map[move] = [];
		
		for material_path in move.spell_video_materials :
			var mat = load_material(material_path);
		
			if mat != null : 
				_attack_to_shader_map[move].append(mat);


func _set_player_bg(entity : EntityController):
	if _entity_to_color_mat_map.has(entity.current_entity):
		var previous = color_layer.material.get_shader_parameter("palette");
		color_layer.material = _entity_to_color_mat_map[entity.current_entity].duplicate() as ShaderMaterial;
		color_layer.material.set_shader_parameter("transition_palette", previous);
		color_layer.material.set_shader_parameter("use_manual_time", false);
		color_layer.texture_repeat = entity.current_entity.entity_thought_repeat_mode;
		
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		
		var property = tween.tween_property(color_layer.material as ShaderMaterial, "shader_parameter/transition", 1.0, 1.0);
		
		if property == null : 
			return;
		else:
			property.set_trans(Tween.TRANS_QUART)
			property.set_ease(Tween.EASE_OUT)
			property.from(0);
	
	if effect_layer_list.size() > 0 && effect_layer_list[0] != null :
		if entity is EnemyController : 
			effect_layer_list[0].get_parent().z_index = 0;
		else :
			effect_layer_list[0].get_parent().z_index = -1;


func _set_spell_bg(spell : Spell, index : int, change_video : bool, change_material : bool, use_entity_palette : bool, palette_transition_duration : float):
	if spell == null && _current_spell != null: 
		# Disabling the following code in case we can later restore this functionality
		# == DISABLED CODE ==
		#var offset_amount = video_layer.stream_position;
		
		#video_layer.stop();
		
		#video_layer.material = _material_main;
		#video_layer.stream = _video_main;
		
		#video_layer.play_video_at(_runtime_main + offset_amount);
		# == END DISABLED CODE ==
		attack_layer.stop();
		attack_layer.visible = false;
		attack_layer.stream = null;
		_current_spell = null;
		
		color_layer.visible = true;
		color_layer.material.set_shader_parameter("transition_palette", attack_layer.material.get_shader_parameter("palette"));
		
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		
		var property = tween.tween_property(color_layer.material as ShaderMaterial, "shader_parameter/transition", 1.0, 0.2);
		
		if property == null : 
			return;
		else:
			property.set_trans(Tween.TRANS_QUART)
			property.set_ease(Tween.EASE_OUT)
			property.from(0);
		
		_is_attacking = false;
		
		for effect_layer in effect_layer_list:
			effect_layer.stop();
			effect_layer.visible = false;
			effect_layer.stream = null;
			effect_layer.material = effect_layer_default_mat.duplicate();
	else :
		if _attack_to_video_map.has(spell):
			# Disabling the following code in case we can later restore this functionality
			# == DISABLED CODE ==
			# Cache video runtime
			#_runtime_main = video_layer.stream_position;
			
			#video_layer.stop();
			
			#var vid = _attack_to_video_map[spell];
			#var mat = _attack_to_shader_map[spell];
			
			#video_layer.material = mat;
			#video_layer.stream = vid;
			
			#video_layer.play_video_at(0);
			# == END DISABLED CODE ==
			var vid = _attack_to_video_map[spell][clamp(index, 0, _attack_to_video_map[spell].size() - 1)];
			var mat = _attack_to_shader_map[spell][clamp(index, 0, _attack_to_shader_map[spell].size() - 1)].duplicate();
			
			attack_layer.visible = true;
			if change_video : attack_layer.stream = vid;
			
			if change_material : 
				var previous = attack_layer.material.get_shader_parameter("palette");
				attack_layer.material = mat;
				attack_layer.material.set_shader_parameter("transition", 0.0);
				
				if use_entity_palette :
					attack_layer.material.set_shader_parameter("transition_palette", attack_layer.material.get_shader_parameter("palette"));
					attack_layer.material.set_shader_parameter("palette", color_layer.material.get_shader_parameter("palette"));
				else:
					attack_layer.material.set_shader_parameter("transition_palette", previous);
				
				var tween = get_tree().create_tween();
				tween.set_parallel(true);
		
				var property = tween.tween_property(attack_layer.material as ShaderMaterial, "shader_parameter/transition", 1.0, palette_transition_duration);
				
				if property == null : 
					return;
				else:
					property.set_trans(Tween.TRANS_QUART)
					property.set_ease(Tween.EASE_OUT)
					property.from(0.0);
				
				attack_layer.material.set_shader_parameter("use_manual_time", true);
			
			if change_video : attack_layer.play_video_at(0);
			
			color_layer.visible = false;
			
			_current_spell = spell;
			_is_attacking = true;
			_attack_time = 0;


func _set_effect_bg(layer : int, spell : Spell, index : int, change_video : bool, change_material : bool, use_entity_palette : bool, palette_transition_duration : float, set_transparent : bool):
	if spell == null && _current_spell != null: 
		if layer >= effect_layer_list.size():
			pass;
		
		var player = effect_layer_list[layer];
		
		player.stop();
		player.visible = false;
		player.stream = null;
	else :
		print("Effect Stuff BG")
		if layer >= effect_layer_list.size():
			pass;
		
		var player = effect_layer_list[layer];
		
		if _attack_to_video_map.has(spell):
			var vid = _attack_to_video_map[spell][clamp(index, 0, _attack_to_video_map[spell].size() - 1)];
			var mat = _attack_to_shader_map[spell][clamp(index, 0, _attack_to_shader_map[spell].size() - 1)].duplicate();
			
			player.visible = true;
			if change_video : player.stream = vid;
			
			if change_material : 
				var previous = player.material.get_shader_parameter("palette");
				player.material = mat;
				player.material.set_shader_parameter("transition", 0.0);
				
				if use_entity_palette :
					player.material.set_shader_parameter("transition_palette", player.material.get_shader_parameter("palette"));
					player.material.set_shader_parameter("palette", color_layer.material.get_shader_parameter("palette"));
				else:
					player.material.set_shader_parameter("transition_palette", previous);
				
				if set_transparent : 
					player.material.set_shader_parameter("palette", effect_layer_default_mat.get_shader_parameter("palette"));
				
				var tween = get_tree().create_tween();
				tween.set_parallel(true);
		
				var property = tween.tween_property(player.material as ShaderMaterial, "shader_parameter/transition", 1.0, palette_transition_duration);
				
				if property == null : 
					return;
				else:
					property.set_trans(Tween.TRANS_QUART)
					property.set_ease(Tween.EASE_OUT)
					property.from(0.0);
				
				# TODO: We will need manual time here to have any sort of visual consistency
				player.material.set_shader_parameter("use_manual_time", true);
			
			if change_video : player.play_video_at(0);


func load_video_full(vid_path : String, mat1_path : String, mat2_path : String, load_type : LoadType, aux : Resource):
	var vid = load_video(vid_path);
	var mat1 = load_material(mat1_path);
	var mat2 = load_material(mat2_path);
	
	if load_type == LoadType.ENTITY:
		_video_main = vid;
		_material_main = mat1;
		_material_ghost = mat2;
		
		video_layer.stream = _video_main;
		video_layer.material = mat1;
		video_layer.texture_repeat = (aux as Entity).entity_video_repeat_mode;
		color_layer.stream = _video_main;
		color_layer.material = mat2;
		color_layer.texture_repeat = (aux as Entity).entity_thought_repeat_mode;
		
		_set_static(false);
		
		video_layer.play_video();
		color_layer.play_video();


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
	video_layer.visible = !active;
	color_layer.visible = !active;
	attack_layer.visible = false;
	
	for effect_layer in effect_layer_list :
		effect_layer.visible = false;
		effect_layer.material = effect_layer_default_mat.duplicate();


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_begin.disconnect(_on_battle_begin);
		EventManager.set_player_bg.disconnect(_set_player_bg);
		EventManager.set_spell_bg.disconnect(_set_spell_bg);
		EventManager.set_effect_bg.disconnect(_set_effect_bg);
		EventManager.register_player.disconnect(_load_entity_spell_data);
		EventManager.register_enemy.disconnect(_load_entity_spell_data);
