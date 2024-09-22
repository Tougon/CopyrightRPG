extends Node2D
class_name Interactable

@export var interact_dialogue : String = "temp";


func highlight(state : bool):
	pass;


func interact():
	if Dialogic.current_timeline != null: return

	Dialogic.start(interact_dialogue)
	get_viewport().set_input_as_handled()
