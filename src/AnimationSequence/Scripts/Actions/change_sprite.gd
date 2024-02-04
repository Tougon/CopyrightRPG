extends AnimationSequenceAction

class_name ASAChangeSprite

@export var index : int;
@export var target : AnimationSequenceAction.Target;
@export var effect_index : int;

func execute(sequence : AnimationSequence):
	var entity : EntityBase;
	var controller : EntityController;
	if target == Target.USER:
		entity = sequence.user;
		controller = (entity as EntityController);
	elif target == Target.TARGET:
		entity = sequence.target[sequence.target_index];
		controller = (entity as EntityController);
	else:
		entity = sequence.effects[effect_index];
	
	if controller && index < controller.current_entity.entity_sprites.size():
		controller.sprite.texture = controller.current_entity.entity_sprites[index];
