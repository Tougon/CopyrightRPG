extends Resource
class_name DialogueCheckGroup

enum CheckType {AND, OR}

@export var interact_dialogue : String = "temp";
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
	
	if success : return interact_dialogue;
	else : return "";
