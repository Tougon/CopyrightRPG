extends AnimationSequenceAction

class_name ASAApplyDamage

@export var vibrate : bool = true;
@export var damage_time : float = 0.35;
@export var damage_delay : float = 0.0;
@export var shake_duration : float = 0.0;
@export var shake_decay : float = 0.35;
@export var force_dodge : bool = true;

func execute(sequence : AnimationSequence):
	var index = sequence.target_index;
	if sequence.spell_data && sequence.spell_data.spell_target == Spell.SpellTarget.RandomEnemyPerHit :
		index = 0;
	
	var dmg = sequence.spell_cast[index].get_current_hit_damage();
	var crit = sequence.spell_cast[index].get_current_hit_critical();
	var hit = sequence.spell_cast[index].get_current_hit_success();
	
	sequence.target[sequence.target_index].last_hit = 0;
	
	sequence.target[sequence.target_index].apply_damage(dmg, crit, vibrate, hit, damage_time, damage_delay, shake_duration, shake_decay, force_dodge);
	sequence.spell_cast[index].increment_hit();
	sequence.applied_damage_this_frame = true;
