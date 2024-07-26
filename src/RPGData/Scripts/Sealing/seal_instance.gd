extends Object
class_name SealInstance

var seal_entity : EntityController;
var seal_source : Spell;
var seal_effect : SealEffectGroup;
var seal_turn_count : int;
var player_side : bool;

func _init(entity : EntityController, source : Spell, effect : SealEffectGroup, turn_count : int, player : bool):
	seal_entity = entity;
	seal_source = source;
	seal_effect = effect;
	seal_turn_count = turn_count;
	player_side = player;
