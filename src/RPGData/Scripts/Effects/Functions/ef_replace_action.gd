extends EffectFunction
class_name EFReplaceAction

@export var target : EffectFunction.Target;
@export var action : Spell;
@export var pick_random : bool = false;
@export var reset_sealing : bool = true;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity != null :
		if pick_random : 
			var actions = entity.move_list.duplicate();
			
			if entity is PlayerController:
				actions.append(entity.default_attack_action);
			
			var index = actions.find(entity.current_action);
			if index > -1:
				actions.remove_at(index);
			
			entity.current_action = actions.pick_random();
			entity.set_target();
		
		elif action != null : 
			entity.current_action = action;
			entity.set_target();
		
		if reset_sealing:
			entity.sealing = false;
