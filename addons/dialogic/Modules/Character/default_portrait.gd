@tool
extends DialogicPortrait

## Default portrait scene.
## The parent class has a character and portrait variable.

@export_group('Main')
@export_file var image := ""


## Load anything related to the given character and portrait
func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void:
	$Portrait.material.set_shader_parameter("shadow_offset", Vector2(0.0, 0.0));
	apply_character_and_portrait(passed_character, passed_portrait)
	apply_texture($Portrait, image)
