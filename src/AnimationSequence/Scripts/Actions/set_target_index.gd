extends AnimationSequenceAction

class_name ASASetTargetIndex

@export var index : int;
@export var set_to_loop : bool = false;

func execute(sequence : AnimationSequence):
	if sequence.spell_data != null && sequence.spell_data.spell_target == Spell.SpellTarget.RandomEnemyPerHit :
		var hit_index = sequence.spell_cast[0].current_hit;
		sequence.target_index = sequence.spell_cast[0].target_index_override[hit_index];
	elif set_to_loop : sequence.target_index = sequence.loops[sequence.loops.size() - 1].num_iterations;
	else : sequence.target_index = index;
