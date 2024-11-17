extends AnimationSequenceAction

class_name ASAConsumeItem

@export var target : AnimationSequenceAction.Target;

func execute(sequence : AnimationSequence):
	print("use the item here")
	
	var entity : EntityBase;
	
	if target == Target.USER:
		entity = sequence.user;
	elif target == Target.TARGET:
		entity = sequence.target[sequence.target_index];
	
	if entity != null:
		for effect in entity.current_item.on_use:
			effect.execute_battle(sequence.user, sequence.target[sequence.target_index]);
		
		entity.consume_item();
