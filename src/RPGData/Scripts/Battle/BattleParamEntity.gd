extends Object
class_name BattleParamEntity

var id : int;
var override_entity : Entity;
var override_weapon_id : int = -1;
var override_armor_id : int = -1;
var override_accessory_id : int = -1;
var override_move_list : Array[Spell];
var override_level : int = -1;
var hp_offset : int = 0;
var mp_offset : int = 0;
var should_award_exp : bool = false;
var modified_exp_amt : int;
