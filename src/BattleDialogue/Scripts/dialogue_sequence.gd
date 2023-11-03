extends Sequence

class_name DialogueSequence;

var canvas : DialogueCanvas;
var dialogue : String;


func _init(in_tree : SceneTree, in_canvas : DialogueCanvas, in_dialogue : String):
	canvas = in_canvas;
	dialogue = in_dialogue;
	super._init(in_tree);


func sequence_start():
	canvas.print_dialogue(dialogue);
	super.sequence_start();


func sequence_loop():
	await canvas.on_dialogue_complete;
	sequence_end();
