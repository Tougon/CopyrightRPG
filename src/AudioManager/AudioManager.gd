extends Node

const MIN_VOLUME_AMOUNT = -80.0;
const MAX_VOLUME_AMOUNT = 0.0;

@export var volume_curve : Curve;
@export var sfx_source_count : int = 15;
@export var common_audio_group : AudioGroup;
@export var bgm_group : AudioGroup;

# Runtime variables
var _runtime_bgm_volume : float;
var _runtime_sfx_volume : float;

var _common_audio_bank : Dictionary;
var _aux_audio_bank : Dictionary;
var _current_bgm_source_index : int = -1;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_bgm_volume(DataManager.preferences.bgm_volume);
	_set_sfx_volume(DataManager.preferences.sfx_volume);
	
	for i in sfx_source_count :
		var sfx_source = AudioStreamPlayer.new();
		sfx_source.name = "SFX_" + str(i+1);
		sfx_source.bus = "SFX";
		$SFX.add_child(sfx_source);
	
	# Clearing this will clear the objects from memory.
	_common_audio_bank = common_audio_group.load_group();
	
	# Event listening
	EventManager.play_bgm.connect(play_bgm);
	EventManager.fade_bgm.connect(fade_bgm);
	EventManager.play_sfx.connect(play_sfx);
	EventManager.change_bgm_volume_preference.connect(_on_bgm_volume_preference_changed);
	EventManager.change_sfx_volume_preference.connect(_on_sfx_volume_preference_changed);
	
	EventManager.load_aux_audio.connect(_load_aux_audio);
	EventManager.unload_aux_audio.connect(_unload_aux_audio);


# Audio loading
func _load_aux_audio(group : AudioGroup):
	if group == null : return;
	
	var audio_bank = group.load_group();
	
	for item in audio_bank.keys():
		if _aux_audio_bank.has(item) :
			if _aux_audio_bank[item] != audio_bank[item]:
				print("ERROR: Duplicate key " + str(item) + ". Loading of value in " + group.name + " skipped.")
			continue;
		
		_aux_audio_bank[item] = audio_bank[item];


func _unload_aux_audio():
	_aux_audio_bank.clear();


# Audio playback
func play_bgm(id : String, fade_time : float, crossfade : bool, start_time : float, start_volume : float):
	var root = $BGM;
	
	if _current_bgm_source_index >= 0 && root.get_child(_current_bgm_source_index).playing :
		_fade_player(root.get_child(_current_bgm_source_index), 0, fade_time, -1, true);
		if !crossfade : await get_tree().create_timer(fade_time).timeout;
	
	var bgm = bgm_group.load_id(id);
	
	if bgm != null:
		_current_bgm_source_index = _get_unused_audio_source(root);
		
		if _current_bgm_source_index < 0 : print("ERROR: Should never occur")
		
		var new_source = root.get_child(_current_bgm_source_index) as AudioStreamPlayer;
		new_source.stream = bgm;
		
		# Gross!
		while(start_time >= bgm.get_length()) : start_time -= bgm.get_length();
		
		new_source.play(start_time);
		
		_fade_player(root.get_child(_current_bgm_source_index), start_volume, fade_time, 0);


func fade_bgm(volume : float, fade_time : float, stop : bool):
	var root = $BGM;
	if _current_bgm_source_index >= 0:
		_fade_player(root.get_child(_current_bgm_source_index), volume, fade_time, -1, stop)


func _fade_player(source : AudioStreamPlayer, amount : float, fade_time : float, start_amount : float = -1, stop : bool = false):
	var log_amount = volume_curve.sample(amount);
	
	var tween = get_tree().create_tween();
	
	var property = tween.tween_property(source, "volume_db", lerp(MIN_VOLUME_AMOUNT, MAX_VOLUME_AMOUNT, log_amount), fade_time);
	
	if start_amount != -1:
		var start_log_amount = volume_curve.sample(start_amount);
		property.from(lerp(MIN_VOLUME_AMOUNT, MAX_VOLUME_AMOUNT, start_log_amount));
	
	if stop :
		tween.finished.connect(func kill_vol_tween(): 
			source.stop();)


func get_bgm_time() -> float:
	var root = $BGM;
	
	for i in root.get_children().size():
		var player = (root.get_child(i) as AudioStreamPlayer);
		if player.playing:
			return player.get_playback_position();
	
	return 0;


func play_sfx(id : String):
	var root = $SFX;
	
	var sfx : AudioStream;
	
	if _common_audio_bank.has(id):
		sfx = _common_audio_bank[id];
	elif _aux_audio_bank.has(id):
		sfx = _aux_audio_bank[id];
	
	if sfx != null:
		var source_index = _get_unused_audio_source(root);
		
		if source_index < 0 : print("ERROR: Should never occur")
		
		var new_source = root.get_child(source_index) as AudioStreamPlayer;
		new_source.stream = sfx;
		new_source.play();


func _get_unused_audio_source(root : Node) -> int:
	for i in root.get_children().size():
		if !(root.get_child(i) as AudioStreamPlayer).playing:
			return i;
	
	return -1;


# Volume Control
func _set_bgm_volume(amount : float):
	_runtime_bgm_volume = amount;
	var bus_index = AudioServer.get_bus_index("BGM");
	_set_bus_volume(bus_index, amount);


func _set_sfx_volume(amount : float):
	_runtime_sfx_volume = amount;
	var bus_index = AudioServer.get_bus_index("SFX");
	_set_bus_volume(bus_index, amount);


func _set_bus_volume(index : int, amount : float):
	# TODO: Curve this as using linear values will make this more severe
	var log_amount = volume_curve.sample(amount);
	AudioServer.set_bus_volume_db(index, lerp(MIN_VOLUME_AMOUNT, MAX_VOLUME_AMOUNT, log_amount));


func _on_bgm_volume_preference_changed(amount : float):
	DataManager.preferences.bgm_volume = amount;
	_set_bgm_volume(amount);


func _on_sfx_volume_preference_changed(amount : float):
	DataManager.preferences.sfx_volume = amount;
	_set_sfx_volume(amount);


func _on_destroy():
	if EventManager != null:
		EventManager.play_bgm.disconnect(play_bgm);
		EventManager.fade_bgm.disconnect(fade_bgm);
		EventManager.play_sfx.disconnect(play_sfx);
		EventManager.change_bgm_volume_preference.disconnect(_on_bgm_volume_preference_changed);
		EventManager.change_sfx_volume_preference.disconnect(_on_sfx_volume_preference_changed);
		
		EventManager.load_aux_audio.disconnect(_load_aux_audio);
