extends EffectFunction
class_name EFPlayAnimation

@export var target : EffectFunction.Target;
@export var animation : AnimationSequenceObject;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if (entity != null && animation != null) :
		var animation_seq = AnimationSequence.new(entity.get_tree(), animation, entity, entity.current_target, [ instance.spell ]);
		EventManager.on_sequence_queue.emit(animation_seq);
