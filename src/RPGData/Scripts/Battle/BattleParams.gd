extends Object
class_name BattleParams

var players : Array[BattleParamEntity]
var enemies : Array[Entity]
var can_flee : bool = true;
var panic_battle : bool = false;

func destroy():
	for player in players:
		if player != null: player.free();
