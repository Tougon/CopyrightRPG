extends Resource
class_name Item

@export_subgroup("Item Naming")
@export var item_name_key : String;
@export var item_description_key : String;

@export_subgroup("Item Parameters")
@export var item_category : TFlag;
@export var item_flags : Array[TFlag];
@export var item_cost : int;
@export var item_sellable : bool;
@export var item_sell_amount : int;
