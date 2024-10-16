extends EntityController
class_name PlayerController

enum ActionType { ATTACK, DEFEND, SPELL, ITEM }

@export var player_id : int;
@export var attack_action : Spell;
@export var defend_action : Spell;
@export var seal_effect : SealEffectGroup;
var prev_action_type : ActionType;


func entity_init(params : BattleParams):
	var hp_mod = 0;
	var mp_mod = 0;
	
	if params != null:
		# If player is null, they are locked. Do not use this entity.
		if params.players[player_id] == null : 
			visible = false;
			return;
		
		level = params.players[player_id].override_level;
		hp_mod = params.players[player_id].hp_offset;
		mp_mod = params.players[player_id].mp_offset;
	else:
		level = 30;
	
	current_entity = params.players[player_id].override_entity;
	super.entity_init(params)
	
	# TODO: Apply additional modifiers and moveset
	current_hp -= hp_mod;
	current_mp -= mp_mod;
	
	await get_tree().process_frame;
	EventManager.register_player.emit(self);
	
	await get_tree().create_timer(1.0).timeout
	#TweenExtensions.shake_position_2d($Sprite2D, 0.28, 35, Vector2(50, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.35);
