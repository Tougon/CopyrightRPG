extends Sequence

class_name HybridSequence

var animation : AnimationSequence;
var dialogue : DialogueSequence;

var _animation_ended : bool = false;
var _dialogue_ended : bool = false;
var _pressed : bool = false;


func _init(in_tree : SceneTree, in_dialogue : DialogueSequence, in_animation : AnimationSequence):
	super._init(in_tree);
	
	dialogue = in_dialogue;
	animation = in_animation;


func sequence_start():
	BattleManager.dialogue_canvas.on_dialogue_complete.connect(_on_dialogue_end);
	animation.sequence_ended.connect(_on_animation_end);
	
	dialogue.sequence_start();
	animation.sequence_start();
	super.sequence_start();


func _on_animation_end():
	_animation_ended = true;


func _on_dialogue_end():
	BattleManager.dialogue_canvas.on_dialogue_complete.disconnect(_on_dialogue_end);
	_dialogue_ended = true;


func sequence_loop():
	while !_animation_ended || !_dialogue_ended:
		await tree.process_frame;
	
	if _pressed:
		BattleManager.dialogue_canvas.clear_dialogue();
		sequence_end();


func sequence_end():
	await tree.process_frame;
	super.sequence_end();


func unhandled_input(event : InputEvent) -> bool:
	if dialogue != null && !_pressed:
		var _dialogue_already_over = _dialogue_ended
		_pressed = dialogue.unhandled_input(event);
		
		if _dialogue_already_over : sequence_end();
		
		return _pressed;
	return false;
