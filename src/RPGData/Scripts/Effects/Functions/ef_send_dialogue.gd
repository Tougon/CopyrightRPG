extends EffectFunction

class_name EFSendDialogue

@export var dialogue_key : String;

# Skeleton function used to run an arbitrary event function
func execute(instance : EffectInstance):
	var user_name = "";
	var user_article_def = "";
	var user_article_indef = "";
	
	var target_name = "";
	var target_article_def = "";
	var target_article_indef = "";
	
	if instance.user != null :
		user_name = instance.user.param.entity_name;
		
		if instance.user.current_entity.generic:
			user_article_def = GrammarManager.get_direct_article(user_name);
			user_article_indef = GrammarManager.get_indirect_article(user_name);
	
	if instance.target != null :
		target_name = instance.target.param.entity_name;
		
		if instance.target.current_entity.generic:
			target_article_def = GrammarManager.get_direct_article(target_name);
			target_article_indef = GrammarManager.get_indirect_article(target_name);
	
	var dialogue = tr(dialogue_key);
	dialogue = dialogue.format({article_indef = user_article_indef, article_def = user_article_def, entity = user_name, t_article_indef = target_article_indef, t_article_def = target_article_def, t_entity = target_name});
	EventManager.on_dialogue_queue.emit(dialogue);
