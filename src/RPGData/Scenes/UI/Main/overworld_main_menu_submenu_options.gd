extends OverworldSubmenu

@export var bgm_slider : Slider;
@export var sfx_slider : Slider;


func _ready():
	super._ready();
	
	bgm_slider.value = DataManager.preferences.bgm_volume;
	sfx_slider.value = DataManager.preferences.sfx_volume;


func set_active(state : bool):
	super.set_active(state);


func _on_bgm_volume_slider_value_changed(value: float) :
	EventManager.change_bgm_volume_preference.emit(value);


func _on_sfx_volume_slider_value_changed(value: float) :
	EventManager.change_sfx_volume_preference.emit(value);
