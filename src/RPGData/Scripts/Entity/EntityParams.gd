extends Object
class_name EntityParams

var entity_name : String;
var entity_name_plural : String;
var entity_description : String;

var entity_gender : Entity.Gender;
var entity_generic : bool;

var entity_hp : int;
var entity_mp : int;
var entity_atk : int;
var entity_def : int;
var entity_sp_atk : int;
var entity_sp_def : int;
var entity_spd : int;
var entity_crit_chance_modifier : float = 1;
var entity_crit_resist_modifier : float = 1;
var entity_dodge_modifier : float = 1;
var entity_luck : float;

var entity_sprites: Array[Texture2D];

func destroy():
	for sprite in entity_sprites:
		if sprite != null: sprite = null
