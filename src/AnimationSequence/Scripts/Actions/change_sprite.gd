extends AnimationSequenceAction

class_name ASAChangeSprite

@export var group : int = -1;
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
	
	if controller != null:
		# -1 is a wildcard that uses the controller's current group
		if group < 0 :
			if group >= controller.param.entity_sprites.size():
				controller.sprite_group = controller.param.entity_sprites.size() - 1;
			else :
				controller.sprite_group = group;
		
		if index < controller.param.entity_sprites[controller.sprite_group].size() :
			controller.sprite.texture = controller.param.entity_sprites[controller.sprite_group][index];
