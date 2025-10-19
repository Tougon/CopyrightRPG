extends EffectFunction
class_name EFAddEntity

@export var use_user : bool = false;
@export var entity_to_add : Entity;

func execute(instance : EffectInstance):
	var new_entity = entity_to_add;
	
	if use_user :
		new_entity = instance.user.current_entity;
	
	if new_entity != null :
		EventManager.add_entity_to_battle.emit(new_entity);
