extends Object

class_name AnimationSequenceLoop;

var start_frame : int;
var num_loops : int;
var num_iterations : int;

func _init(start : int, loops : int):
	start_frame = start;
	num_loops = loops;
	num_iterations = 0;
