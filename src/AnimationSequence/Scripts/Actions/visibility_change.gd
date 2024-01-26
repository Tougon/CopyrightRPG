extends AnimationSequenceAction

class_name ASAVisibilityChange

@export var visible : bool = true;
@export var target : AnimationSequenceAction.Target;
@export var effect_index : int;
@export var node_path : String = "";

func execute(sequence : AnimationSequence):
	var entity : EntityBase;
	if target == Target.USER:
		entity = sequence.user;
	elif target == Target.TARGET:
		entity = sequence.target[sequence.target_index];
	else:
		entity = sequence.effects[effect_index];
	
	var node = entity.get_node(NodePath(node_path));
	
	if node != null : node.visible = visible;
