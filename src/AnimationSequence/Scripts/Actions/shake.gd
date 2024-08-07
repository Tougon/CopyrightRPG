extends AnimationSequenceAction

class_name ASAShake

@export var target : AnimationSequenceAction.Target;
@export var effect_index : int;
var node_path : String = "Sprite2D";
@export var duration : float;
@export var vibration_speed : float;
@export var strength : Vector2;
@export var transition_type : Tween.TransitionType = Tween.TRANS_QUAD;
@export var ease_type : Tween.EaseType = Tween.EASE_IN_OUT;
@export var decay_factor : float = 0.5;

func execute(sequence : AnimationSequence):
	var entity : EntityBase;
	if target == Target.USER:
		entity = sequence.user;
	elif target == Target.TARGET:
		entity = sequence.target[sequence.target_index];
	else:
		entity = sequence.effects[effect_index];
		
	TweenExtensions.shake_position_2d(entity.get_node(NodePath(node_path)), duration, vibration_speed, strength, transition_type, ease_type, decay_factor);
