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
var _current_bgm_source_index : int = -1;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_bgm_volume(DataManager.preferences.bgm_volume);
	_set_sfx_volume(DataManager.preferences.sfx_volume);
	
	for i in sfx_source_count :
		var sfx_source = AudioStreamPlayer.new();
		sfx_source.name = "SFX_" + str(i+1);
		$SFX.add_child(sfx_source);
	
	# Clearing this will clear the objects from memory.
	_common_audio_bank = common_audio_group.load_group();
	
	# Event listening
	EventManager.play_bgm.connect(play_bgm);
	EventManager.play_sfx.connect(play_sfx);
	EventManager.change_bgm_volume_preference.connect(_on_bgm_volume_preference_changed);
	EventManager.change_sfx_volume_preference.connect(_on_sfx_volume_preference_changed);


func play_bgm(id : String, fade_time : float, crossfade : bool):
	var root = $BGM;
	
	if _current_bgm_source_index >= 0:
		print("TBD fading operations");
	
	var bgm = bgm_group.load_id(id);
	
	if bgm != null:
		print("TBD Fade in");
		_current_bgm_source_index = _get_unused_audio_source(root);
		
		if _current_bgm_source_index < 0 : print("ERROR: Should never occur")
		
		var new_source = root.get_child(_current_bgm_source_index) as AudioStreamPlayer;
		new_source.stream = bgm;
		new_source.play();


func play_sfx(id : String):
	var root = $SFX;
	
	var sfx : AudioStream;
	# TODO: aux soundbank fetching
	if _common_audio_bank.has(id):
		sfx = _common_audio_bank[id];
	
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
