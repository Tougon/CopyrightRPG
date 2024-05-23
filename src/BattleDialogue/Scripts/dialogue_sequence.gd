extends Sequence

class_name DialogueSequence;

const PRESS_ADVANCE : bool = true;

var canvas : DialogueCanvas;
var dialogue : String;
var is_message : bool;
var loop : bool;

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
	
	canvas.on_dialogue_complete.connect(on_dialogue_complete);
	canvas.print_dialogue(dialogue, PRESS_ADVANCE);
	
	if !is_message:
		super.sequence_start();


func sequence_loop():
	# originally awaited canvas.on_dialogue_complete.
	loop = true;
	
	while loop: 
		await tree.process_frame;
	
	if !is_message:
		if !PRESS_ADVANCE :
			sequence_end();


func on_dialogue_complete():
	canvas.on_dialogue_complete.disconnect(on_dialogue_complete);
	loop = false;


func unhandled_input(event : InputEvent) -> bool:
	if PRESS_ADVANCE && !is_message:
		if (event.is_action_pressed("ui_accept") || event.is_action_pressed("advance_dialogue")):
			if loop :
				on_dialogue_complete();
				canvas.skip_dialogue_to_end();
			else :
				canvas.clear_dialogue();
				sequence_end();
			
			return true;
	
	return false;
