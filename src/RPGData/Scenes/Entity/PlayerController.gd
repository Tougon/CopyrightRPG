extends EntityController
class_name PlayerController

enum ActionType { ATTACK, DEFEND, SPELL, ITEM }

@export var attack_action : Spell;
@export var defend_action : Spell;
@export var seal_effect : Effect;
var prev_action_type : ActionType;


# Called when the node enters the scene tree for the first time.
func entity_init():
	
	# TODOGAME: Fetch levels and anything else from player data
	
	super.entity_init()
	await get_tree().process_frame;
	EventManager.register_player.emit(self);
	
	await get_tree().create_timer(1.0).timeout
	#TweenExtensions.shake_position_2d($Sprite2D, 0.28, 35, Vector2(50, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.35);
