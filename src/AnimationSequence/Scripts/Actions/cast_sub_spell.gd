extends AnimationSequenceAction

class_name ASACastSubspell

@export var spell : Spell;
@export var vibrate : bool = true;
@export var damage_time : float = 0.35;
@export var damage_delay : float = 0;
@export var show_ui : bool = true;

func execute(sequence : AnimationSequence):
	if spell == null : return;
	
	var user = sequence.user;
	var targets : Array[EntityController];
	var possible_targets = user.get_possible_targets(spell);
	
	match spell.spell_target:
		Spell.SpellTarget.All:
			targets = possible_targets.duplicate();
		Spell.SpellTarget.SingleEnemy:
			if sequence.spell_data.spell_target == Spell.SpellTarget.SingleEnemy : 
				targets = possible_targets.duplicate();
			elif possible_targets.size() > 0:
				targets.append(possible_targets[0]);
		Spell.SpellTarget.RandomEnemy:
			if possible_targets.size() > 0:
				targets.append(possible_targets[0]);
		Spell.SpellTarget.RandomEnemyPerHit:
			targets = possible_targets.duplicate();
		Spell.SpellTarget.AllEnemy:
			targets = possible_targets.duplicate();
		Spell.SpellTarget.AllEnemyExcept:
			for target in possible_targets:
				if !sequence.target.has(target):
					targets.append(target);
		Spell.SpellTarget.SingleParty:
			if sequence.spell_data.spell_target == Spell.SpellTarget.SingleParty : 
				targets = possible_targets.duplicate();
			elif possible_targets.size() > 0:
				targets.append(possible_targets[0]);
		Spell.SpellTarget.AllParty:
			targets = possible_targets.duplicate();
		Spell.SpellTarget.Self:
			targets.append(sequence.user)
	
	var spell_cast = spell.cast(user, targets);
	
	for cast in spell_cast:
		var dmg = 0;
		var crit = false;
		var hit = false;
		
		for i in cast.get_number_of_hits():
			dmg += cast.get_current_hit_damage();
			crit = crit || cast.get_current_hit_critical();
			hit = hit || cast.get_current_hit_success();
			cast.increment_hit();
		
		cast.target.apply_damage(dmg, crit, vibrate, hit, damage_time, damage_delay);
		
		if show_ui && hit : cast.target.update_hp_ui();
		if dmg > 0:
			if spell.animation_sequence :
				var animation_seq = AnimationSequence.new(user.get_tree(), spell.animation_sequence, user, [ cast.target ], [ cast.spell ]);
				animation_seq.sequence_start();
			
			if !BattleManager.async_damage_text:
				var messages : Array[String];
				if crit : 
					if !BattleManager.async_crit_text: 
						messages.append(_format_dialogue(tr("T_BATTLE_ACTION_CRITICAL_SINGLE"), spell.target.param.entity_name, spell.target.current_entity));
				
				var damage_msg = _format_dialogue(tr("T_BATTLE_ACTION_DAMAGE"), cast.target.param.entity_name, cast.target.current_entity);
				damage_msg = damage_msg.format({damage = str(cast.get_damage_applied())});
				messages.append(damage_msg);
				
				if messages.size() > 0 :
					for message in messages :
						EventManager.on_dialogue_queue.emit(message);


# Helper function for dialogue formatting. Should really move this to grammar manager.
func _format_dialogue(dialogue : String, name : String, entity : Entity) -> String:
	var entity_name = name;
	
	if entity.generic : 
		return dialogue.format({article_indef = GrammarManager.get_indirect_article(entity_name), article_def = GrammarManager.get_direct_article(name), entity = name, pronoun1 = GrammarManager.get_pronoun(entity.gender, 1), pronoun2 = GrammarManager.get_pronoun(entity.gender, 2), pronoun3 = GrammarManager.get_pronoun(entity.gender, 3), pronoun4 = GrammarManager.get_pronoun(entity.gender, 4)});
	else:
		return dialogue.format({article_indef = "", article_def = "", entity = name, pronoun1 = GrammarManager.get_pronoun(entity.gender, 1), pronoun2 = GrammarManager.get_pronoun(entity.gender, 2), pronoun3 = GrammarManager.get_pronoun(entity.gender, 3), pronoun4 = GrammarManager.get_pronoun(entity.gender, 4)});
