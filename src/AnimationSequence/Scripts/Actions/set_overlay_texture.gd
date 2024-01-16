extends AnimationSequenceAction

class_name ASASetOverlayTexture

@export var target : AnimationSequenceAction.Target;
@export var texture : Texture2D;

func execute(sequence : AnimationSequence):
	var entity : EntityController;
	if target == Target.USER:
		entity = sequence.user;
	else:
		entity = sequence.target[sequence.target_index];
	
	entity.set_overlay_sprite(texture);
