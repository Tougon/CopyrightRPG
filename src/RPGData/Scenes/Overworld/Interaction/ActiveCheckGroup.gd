extends Resource
class_name ActiveCheckGroup

enum CheckType {AND, OR}

@export var active_state : bool = true;
@export var check_type : CheckType;
@export var active_conditions : Array[QuestCheck];

func determine_dialogue() -> String:
	var success = true;
	
	for i in active_conditions.size():
		success = active_conditions[i].check();
		
		if check_type == CheckType.AND && !success:
			break;
		
		if check_type == CheckType.OR && success:
			break;
	
	if success : return str(active_state);
	else : return "";
