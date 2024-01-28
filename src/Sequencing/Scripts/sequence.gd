extends Object

class_name Sequence

signal sequence_started();
signal sequence_ended();

var active : bool = false;
var tree : SceneTree;

func _init(in_tree : SceneTree):
	tree = in_tree


func sequence_start():
	active = true;
	sequence_loop();
	sequence_started.emit();


func sequence_loop():
	await tree.process_frame;
	sequence_end();


func sequence_end():
	active = false;
	sequence_ended.emit();
	await tree.process_frame;
	self.free();


func unhandled_input(event : InputEvent) -> bool:
	return false;
