extends FieldEffectFunction

class_name FEFSendHybrid

@export var dialogue_key : String;
@export var single_instance : bool = false;
@export var side : FieldEffectFunction.Side;
@export var animation : AnimationSequenceObject;

# Skeleton function used to run an arbitrary event function
func execute(field_effect : FieldEffect, players : Array[EntityController], enemies : Array[EntityController]):
	var key = dialogue_key;
	var dialogue = tr(key);
	var animation_seq = null;
	
	if single_instance :
		animation_seq = AnimationSequence.new(BattleScene.Instance.get_tree(), animation, players[0], [], []);
	else :
		var all = players.duplicate();
		all.append_array(enemies);
		
		animation_seq = AnimationSequence.new(BattleScene.Instance.get_tree(), animation, players[0], all, []);
	
	var dialogue_seq = DialogueSequence.new(BattleScene.Instance.get_tree(), BattleManager.dialogue_canvas, dialogue.to_upper());
	var sequence = HybridSequence.new(BattleScene.Instance.get_tree(), dialogue_seq, animation_seq);
	EventManager.on_sequence_queue.emit(sequence);
