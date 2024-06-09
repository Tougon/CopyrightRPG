extends Object

class_name AnimationSequenceLoop;

var start_frame : int;
var start_order : int;
var num_loops : int;
var num_iterations : int;

func _init(start : int, order : int, loops : int):
	start_frame = start;
	start_order = order;
	num_loops = loops;
	num_iterations = 0;
