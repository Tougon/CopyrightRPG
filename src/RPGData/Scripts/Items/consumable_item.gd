extends Item

class_name ConsumableItem

@export_subgroup("Consumable Parameters")
@export var on_use : Array[ItemFunction];
@export var use_battle : bool;
@export var battle_effect : Spell;
@export var use_overworld : bool;
