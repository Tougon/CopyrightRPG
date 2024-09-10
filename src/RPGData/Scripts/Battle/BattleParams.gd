extends Object
class_name BattleParams

var players : Array[BattleParamEntity]

func destroy():
	for player in players:
		if player != null: player.free();
