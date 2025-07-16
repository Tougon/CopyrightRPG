extends SpellOverworldFunction

class_name SOFuncCanHeal

@export var target : Target;

func execute(user : int, target : int, spell : Spell) -> bool:
	var index = user;
	if target == Target.TARGET : index = target;
	
	if index < DataManager.party_data.size() && index >= 0:
		var current_state = DataManager.party_data[index];
		return !current_state.status.has("Doom")
	else:
		return false;
