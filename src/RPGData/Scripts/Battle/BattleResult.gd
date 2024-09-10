extends Object
class_name BattleResult

var victory : bool;
var exp : int;

var players : Array[BattleParamEntity]

func destroy():
	for player in players:
		if player != null: player.free();
