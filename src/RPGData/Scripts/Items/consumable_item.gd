extends Item

class_name ConsumableItem

enum ItemCheckType { AND, OR }

@export_subgroup("Consumable Parameters")
@export var on_use : Array[ItemFunction];
@export var use_battle : bool;
@export var battle_effect : Spell;
@export var use_overworld : bool;
@export var check_can_use : Array[ItemFunction];
@export var check_type : ItemCheckType;
var success : bool = true;


func check_can_use_item_overworld(index : int) -> bool:
	success = true;
	
	for function in check_can_use:
		if function == null : continue;
		function.execute_overworld(index, self);
		
		if check_type == ItemCheckType.AND && success == false:
			return false;
		elif check_type == ItemCheckType.OR && success == true:
			return true;
	
	return true;


func check_can_use_item_battle(user : EntityController, target : EntityController) -> bool:
	success = true;
	
	for function in check_can_use:
		if function == null : continue;
		function.execute_battle(user, target, self);
		
		if check_type == ItemCheckType.AND && success == false:
			return false;
		elif check_type == ItemCheckType.OR && success == true:
			return true;
	
	return true;
