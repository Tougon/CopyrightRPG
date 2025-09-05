extends Resource
class_name QuestCheck

enum CheckType {ACTIVE, COMPLETE, FAILED}

@export var quest_name : String;
@export var check_type : CheckType;
@export var use_step : bool;
@export var step_name : String;
@export var negate : bool;


func check():
	var quest_instance = QuestManager.get_player_quest(quest_name);
	
	match check_type:
		CheckType.ACTIVE:
			
			# If this quest is completed or failed, it's not active.
			if quest_instance.size() <= 0 || QuestManager.is_quest_complete(quest_name) || QuestManager.is_quest_failed(quest_name):
				return negate;
			
			if quest_instance.size() > 0:
				if use_step : 
					var step = QuestManager.get_current_step(quest_name)["details"];
					if step_name == step : return !negate;
					else : return negate;
				else : return !negate;
			return negate;
		
		CheckType.COMPLETE:
			if quest_instance.size() <= 0 : return false;
			
			if negate : return !QuestManager.is_quest_complete(quest_name);
			else : return QuestManager.is_quest_complete(quest_name);
		
		CheckType.FAILED:
			if quest_instance.size() <= 0 : return false;
			
			if negate : return !QuestManager.is_quest_failed(quest_name);
			else : return QuestManager.is_quest_failed(quest_name);
	
	return false;
