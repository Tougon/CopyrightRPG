extends Node2D
class_name Interactable

@export var default_dialogue : String = "temp";
@export var additional_dialogue : Array[DialogueCheckGroup];


func highlight(state : bool):
	pass;


func interact():
	if Dialogic.current_timeline != null: return

	Dialogic.start(_get_interact_dialogue())
	get_viewport().set_input_as_handled()


func _get_interact_dialogue():
	for check in additional_dialogue:
		var result = check.determine_dialogue();
		
		if result != "" : return result;
	
	return default_dialogue;
