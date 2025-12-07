extends EffectFunction

class_name EFSendDialogue

@export var dialogue_key : String;

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
		user_name = "[color=FFFF00]" + instance.user_name + "[/color]";
		
		user_pronouns.append(GrammarManager.get_pronoun(instance.user_gender, 1));
		user_pronouns.append(GrammarManager.get_pronoun(instance.user_gender, 2));
		user_pronouns.append(GrammarManager.get_pronoun(instance.user_gender, 3));
		user_pronouns.append(GrammarManager.get_pronoun(instance.user_gender, 4));
		
		if instance.user_entity.generic && BattleScene.Instance.enemy_type_count[instance.user_entity] <= 1:
			user_article_def = GrammarManager.get_direct_article(user_name);
			user_article_indef = GrammarManager.get_indirect_article(user_name);
	
	if instance.target != null :
		target_name = "[color=FFFF00]" + instance.target_name + "[/color]";
		
		target_pronouns.append(GrammarManager.get_pronoun(instance.target_gender, 1));
		target_pronouns.append(GrammarManager.get_pronoun(instance.target_gender, 2));
		target_pronouns.append(GrammarManager.get_pronoun(instance.target_gender, 3));
		target_pronouns.append(GrammarManager.get_pronoun(instance.target_gender, 4));
		
		if instance.target_entity.generic && BattleScene.Instance.enemy_type_count[instance.target_entity] <= 1:
			target_article_def = GrammarManager.get_direct_article(target_name);
			target_article_indef = GrammarManager.get_indirect_article(target_name);
	
	var key = dialogue_key;
	if key == "cache" : key = instance.data["dialogue_key"];
	
	var dialogue = tr(key);
	var spell_name = "";
	
	if instance.spell_data != null : 
		if instance.spell_data.spell_name_key.is_empty() :
			if instance.user != null : 
				var generic = tr("T_SPELL_GENERIC");
				generic = generic.format({article_def = user_article_def});
				generic = generic.format({entity = instance.user_name});
				spell_name = generic;
		
		else : spell_name = tr(instance.spell_data.spell_name_key);
	else :
		print("From Seal")
		spell_name = tr("T_SEAL_GENERIC");
	
	dialogue = dialogue.format({article_indef = user_article_indef, article_def = user_article_def, entity = user_name, t_article_indef = target_article_indef, t_article_def = target_article_def, t_entity = target_name, spell = spell_name});
	dialogue = dialogue.format({user_pronoun1 = user_pronouns[0], user_pronoun2 = user_pronouns[1], user_pronoun3 = user_pronouns[2], user_pronoun4 = user_pronouns[3]});
	dialogue = dialogue.format({target_pronoun1 = target_pronouns[0], target_pronoun2 = target_pronouns[1], target_pronoun3 = target_pronouns[2], target_pronoun4 = target_pronouns[3]});
	
	EventManager.on_dialogue_queue.emit(dialogue);
