extends Object
class_name BattleParams

var players : Array[BattleParamEntity]
var enemies : Array[Entity]
var can_flee : bool = true;

func destroy():
	for player in players:
		if player != null: player.free();
