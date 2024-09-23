extends Resource
class_name QuestDatabase

# Database representing a list of every quest in the game
@export var quests: Array[QuestDatabaseEntry];


func get_quest_resource(quest_name : String) -> QuestResource:
	for quest in quests:
		if quest.quest_name == quest_name : return quest.quest;
	
	return null;
