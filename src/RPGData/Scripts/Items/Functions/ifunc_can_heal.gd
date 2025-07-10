extends ItemFunction

class_name IFuncCanHeal

@export var target : Target;

func execute_overworld(index : int, item : Item = null, preview : bool = false, result : ItemResult = null):
	if index < DataManager.party_data.size() && index >= 0:
		var current_state = DataManager.party_data[index];
		item.success = !current_state.status.has("Doom")
	else:
		item.success = false;


func execute_battle(user : EntityController, target : EntityController, item : Item = null):
	var entity : EntityController;
	if self.target == Target.USER: entity = user
	elif self.target == Target.TARGET: entity = target;
	
	if entity != null:
		item.success = entity.can_heal;
	else : item.success = false;
