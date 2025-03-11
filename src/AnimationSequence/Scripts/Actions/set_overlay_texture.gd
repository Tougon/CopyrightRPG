extends AnimationSequenceAction

class_name ASASetOverlayTexture

@export var target : AnimationSequenceAction.Target;
@export_file("*.png") var texture_path: String;

var texture : Texture2D;

func warmup():
	if ResourceLoader.exists(texture_path, "Texture2D"):
		ResourceLoader.load_threaded_request(texture_path, "Texture2D")

func execute(sequence : AnimationSequence):
	# Load the texture
	var result = ResourceLoader.load_threaded_get_status(texture_path);
	
	if result == ResourceLoader.THREAD_LOAD_LOADED:
		texture = ResourceLoader.load_threaded_get(texture_path) as Texture2D;
	
	if texture == null:
		print("ERROR: Failed to load texture at " + texture_path)
		return;
	
	var entity : EntityController;
	if target == Target.USER:
		entity = sequence.user;
	else:
		entity = sequence.target[sequence.target_index];
	
	entity.set_overlay_sprite(texture);


func cooldown():
	texture = null;
