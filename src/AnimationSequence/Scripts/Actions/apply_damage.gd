extends AnimationSequenceAction

class_name ASAApplyDamage

@export var vibrate : bool = true;
@export var damage_time : float = 0.35;

func execute(sequence : AnimationSequence):
	var index = sequence.target_index;
	if sequence.spell_data && sequence.spell_data.spell_target == Spell.SpellTarget.RandomEnemyPerHit :
		index = 0;
	
	var dmg = sequence.spell_cast[index].get_current_hit_damage();
	var crit = sequence.spell_cast[index].get_current_hit_critical();
	var hit = sequence.spell_cast[index].get_current_hit_success();
	
	sequence.target[sequence.target_index].apply_damage(dmg, crit, vibrate, hit, damage_time);
	sequence.spell_cast[index].increment_hit();
