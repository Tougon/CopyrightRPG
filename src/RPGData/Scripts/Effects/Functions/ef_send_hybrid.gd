extends EffectFunction

class_name EFSendHybrid

@export var dialogue_key : String;
@export var target : EffectFunction.Target;
@export var animation : AnimationSequenceObject;

# Skeleton function used to run an arbitrary event function
func execute(instance : EffectInstance):
	var user_name = "";
	var user_article_def = "";
	var user_article_indef = "";
	var user_pronouns = [];
	
	var target_name = "";
	var target_article_def = "";
	var target_article_indef = "";
	var target_pronouns = [];
	
	if instance.user != null :
		user_name = instance.user.param.entity_name;
		
		user_pronouns.append(GrammarManager.get_pronoun(instance.user.param.entity_gender, 1));
		user_pronouns.append(GrammarManager.get_pronoun(instance.user.param.entity_gender, 2));
		user_pronouns.append(GrammarManager.get_pronoun(instance.user.param.entity_gender, 3));
		user_pronouns.append(GrammarManager.get_pronoun(instance.user.param.entity_gender, 4));
		
		if instance.user.current_entity.generic && BattleScene.Instance.enemy_type_count.has(instance.user) && BattleScene.Instance.enemy_type_count[instance.user] <= 1:
			user_article_def = GrammarManager.get_direct_article(user_name);
			user_article_indef = GrammarManager.get_indirect_article(user_name);
	
	if instance.target != null :
		target_name = instance.target.param.entity_name;
		
		target_pronouns.append(GrammarManager.get_pronoun(instance.target.param.entity_gender, 1));
		target_pronouns.append(GrammarManager.get_pronoun(instance.target.param.entity_gender, 2));
		target_pronouns.append(GrammarManager.get_pronoun(instance.target.param.entity_gender, 3));
		target_pronouns.append(GrammarManager.get_pronoun(instance.target.param.entity_gender, 4));
		
		if instance.target.current_entity.generic && BattleScene.Instance.enemy_type_count.has(instance.target) && BattleScene.Instance.enemy_type_count[instance.target] <= 1:
			target_article_def = GrammarManager.get_direct_article(target_name);
			target_article_indef = GrammarManager.get_indirect_article(target_name);
	
	var dialogue = tr(dialogue_key);
	var spell_name = "";
	if instance.spell_data != null : spell_name = tr(instance.spell_data.spell_name_key);
	dialogue = dialogue.format({article_indef = user_article_indef, article_def = user_article_def, entity = user_name, t_article_indef = target_article_indef, t_article_def = target_article_def, t_entity = target_name, spell = spell_name});
	dialogue = dialogue.format({user_pronoun1 = user_pronouns[0], user_pronoun2 = user_pronouns[1], user_pronoun3 = user_pronouns[2], user_pronoun4 = user_pronouns[3]});
	dialogue = dialogue.format({target_pronoun1 = target_pronouns[0], target_pronoun2 = target_pronouns[1], target_pronoun3 = target_pronouns[2], target_pronoun4 = target_pronouns[3]});
	
	var animation_seq = null;
	
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if (entity != null && animation != null) :
		animation_seq = AnimationSequence.new(entity.get_tree(), animation, entity, entity.current_target, [ instance.spell ]);
	
	var dialogue_seq = DialogueSequence.new(entity.get_tree(), BattleManager.dialogue_canvas, dialogue.to_upper());
	var sequence = HybridSequence.new(entity.get_tree(), dialogue_seq, animation_seq);
	EventManager.on_sequence_queue.emit(sequence);
