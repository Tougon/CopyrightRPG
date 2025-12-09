extends Item

class_name EquipmentItem

@export_subgroup("Equipment Parameters")
enum EquipmentType { Weapon, Armor, Accessory }
@export var equipment_type : EquipmentType;
@export var hp_mod : int;
@export var mp_mod : int;
@export var atk_mod : int;
@export var def_mod : int;
@export var mag_mod : int;
@export var res_mod : int;
@export var spd_mod : int;
@export var lck_mod : float;
@export var equipment_effects : Array[Effect];
@export var universal : bool = true;
@export var allowed_entities : Array[int];
