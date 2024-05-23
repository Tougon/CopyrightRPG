extends Control

class_name Sequencer

var current_sequence: Sequence;
var sequence_queue: Array[Sequence];

# Called when the node enters the scene tree for the first time.
func _ready():
	tree_exiting.connect(_on_destroy);
	EventManager.on_sequence_queue.connect(_on_sequence_queue);
	EventManager.on_sequence_queue_first.connect(_on_sequence_queue_first);


func _on_sequence_queue(sequence):
	if sequence is Sequence:
		if sequence_queue.size() > 0 || current_sequence != null:
			sequence_queue.append(sequence);
		else:
			_play_sequence(sequence);


func _on_sequence_queue_first(sequence):
	if sequence is Sequence:
		if sequence_queue.size() > 0 || current_sequence != null:
			sequence_queue.insert(0, sequence);
		else:
			_play_sequence(sequence);


func _play_sequence(sequence):
	current_sequence = sequence;
	current_sequence.sequence_ended.connect(_on_sequence_ended);
	current_sequence.sequence_start();


func _on_sequence_ended():
	current_sequence.sequence_ended.disconnect(_on_sequence_ended);
	current_sequence = null;
	
	if sequence_queue.size() > 0:
		var sequence = sequence_queue[0];
		sequence_queue.erase(sequence);
		_play_sequence(sequence);
	else:
		EventManager.on_sequence_queue_empty.emit();


func is_sequence_playing_or_queued() -> bool:
	return sequence_queue.size() > 0 || current_sequence != null;


func _unhandled_input(event):
	if current_sequence != null:
		var result = current_sequence.unhandled_input(event);
		
		if result :
			accept_event();


func _on_destroy():
	if EventManager != null:
		EventManager.on_sequence_queue.disconnect(_on_sequence_queue);
		EventManager.on_sequence_queue_first.disconnect(_on_sequence_queue_first);
