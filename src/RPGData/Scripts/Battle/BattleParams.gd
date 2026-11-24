extends Object
class_name BattleParams

var players : Array[BattleParamEntity]
var enemies : Array[Entity]
var can_flee : bool = true;
var panic_battle : bool = false;
var tutorial : Encounter.Tutorial;

var video : String;
var video_mat : String;
var bgm : String;

func destroy():
	for player in players:
		if player != null: player.free();
