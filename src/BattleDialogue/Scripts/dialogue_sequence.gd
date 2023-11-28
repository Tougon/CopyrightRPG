extends Sequence

class_name DialogueSequence;

var canvas : DialogueCanvas;
var dialogue : String;
var is_message : bool;

func _init(in_tree : SceneTree, in_canvas : DialogueCanvas, in_dialogue : String, is_message : bool = false):
	canvas = in_canvas;
	dialogue = in_dialogue;
	super._init(in_tree);
	
	if is_message:
		sequence_start();


func sequence_start():
	# Mainly used for messages but should cause no problems elsewhere
	while canvas.is_printing:
		await tree.process_frame;
		
	canvas.print_dialogue(dialogue);
	
	if !is_message:
		super.sequence_start();


func sequence_loop():
	await canvas.on_dialogue_complete;
	
	if !is_message:
		sequence_end();
