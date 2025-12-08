extends CutsceneObject
class_name DialogueTrigger

@export var default_active_state : bool = true;
@export var additional_active_state : Array[ActiveCheckGroup];
@export var default_dialogue : String = "temp";
@export var additional_dialogue : Array[DialogueCheckGroup];


func _ready():
	super._ready();
	
	QuestManager.new_quest_added.connect(_on_add_quest)
	QuestManager.step_updated.connect(_on_update_step)
	QuestManager.step_complete.connect(_on_update_step)
	QuestManager.next_step.connect(_on_update_step)
	QuestManager.quest_completed.connect(_on_quest_complete)
	QuestManager.quest_failed.connect(_on_quest_failed)
	DataManager.on_data_loaded.connect(_update_active_state)
	
	_update_active_state();


func _exit_tree():
	QuestManager.new_quest_added.disconnect(_on_add_quest)
	QuestManager.step_updated.disconnect(_on_update_step)
	QuestManager.step_complete.disconnect(_on_update_step)
	QuestManager.next_step.disconnect(_on_update_step)
	QuestManager.quest_completed.disconnect(_on_quest_complete)
	QuestManager.quest_failed.disconnect(_on_quest_failed)
	DataManager.on_data_loaded.disconnect(_update_active_state)


func _on_add_quest(quest_name):
	_update_active_state();


func _on_update_step(step):
	_update_active_state();


func _on_quest_complete(quest):
	_update_active_state();


func _on_quest_failed(quest):
	_update_active_state();


func _update_active_state():
	var active = _get_active_state();
	# For completely unknown reasons, we need this self here.
	self.visible = active;
	for child in get_children(false):
		child.visible = active;
	$Collider/CollisionShape2D.disabled = !active;


func interact():
	if Dialogic.current_timeline != null: return

	Dialogic.start(_get_interact_dialogue())
	get_viewport().set_input_as_handled()


func _get_active_state() -> bool:
	if additional_active_state == null || additional_active_state.size() == 0 : return default_active_state;
	
	for check in additional_active_state:
		var result = check.determine_dialogue();
		
		if result != "" : return result == "true";
	
	return false;


func _get_interact_dialogue() -> String:
	if additional_dialogue == null : return default_dialogue;
	
	for check in additional_dialogue:
		var result = check.determine_dialogue();
		
		if result != "" : return result;
	
	return default_dialogue;


func _on_body_entered(body: Node2D) -> void:
	if !can_process() : return;
	if !(body is RPGPlayerController) : return;
	if Dialogic.current_timeline != null: return
	
	Dialogic.start(_get_interact_dialogue())
