extends Object
class_name BattleResult

var victory : bool;
var fled : bool;
var exp : int;

var players : Array[BattleParamEntity]
var enemies : Array[String]
var player_items : Dictionary
var reward_items : Dictionary

func destroy():
	for player in players:
		if player != null: player.free();
