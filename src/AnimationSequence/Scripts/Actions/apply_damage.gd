extends AnimationSequenceAction

class_name ASAApplyDamage

@export var vibrate : bool = true;
@export var damage_time : float = 0.35;
@export var damage_delay : float = 0.0;
@export var shake_duration : float = 0.0;
@export var shake_decay : float = 0.35;
@export var force_dodge : bool = true;
@export var effect_user : bool = false;

# NOTE: Not the biggest fan of this but I fail to see a more elegant solution
@export var manual_override : bool;
@export var use_fixed_damage : bool = true;
@export var damage_amount : int;
@export_range(0, 1) var percent_amount : float;

func execute(sequence : AnimationSequence):
	var target = sequence.target[sequence.target_index];
	if effect_user : target = sequence.user;
	
	if manual_override : 
		var manual_dmg = damage_amount;
		
		if !use_fixed_damage :
			var max = target.max_hp as float;
			manual_dmg = roundi((max * percent_amount))
		
		target.apply_damage(manual_dmg, false, vibrate, true, damage_time, damage_delay, shake_duration, shake_decay, force_dodge);
		sequence.applied_damage_this_frame = true;
		return;
	
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
