extends AnimationSequenceAction

class_name ASAShake

@export var target : AnimationSequenceAction.Target;
var node_path : String = "Sprite2D";
var duration : float;
var vibration_speed : float;
var strength : Vector2;
var transition_type : Tween.TransitionType = Tween.TRANS_QUAD;
var ease_type : Tween.EaseType = Tween.EASE_IN_OUT;
var decay_factor : float = 0.5;

func execute(sequence : AnimationSequence):
	var entity : EntityController;
	if target == Target.USER:
		entity = sequence.user;
	else:
		entity = sequence.target[sequence.target_index];
		
	TweenExtensions.shake_position_2d(entity.get_node(NodePath(node_path)), duration, vibration_speed, strength, transition_type, ease_type, decay_factor);
