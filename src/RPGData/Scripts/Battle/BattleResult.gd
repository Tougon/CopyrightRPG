extends Object
class_name BattleResult

var victory : bool;
var exp : int;

var players : Array[BattleParamEntity]
var enemies : Array[String]

func destroy():
	for player in players:
		if player != null: player.free();
