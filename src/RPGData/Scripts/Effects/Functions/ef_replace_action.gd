extends EffectFunction
class_name EFReplaceAction

@export var target : EffectFunction.Target;
@export var action : Spell;
@export var use_previous : bool = false;
@export var pick_random : bool = false;
@export var reset_sealing : bool = true;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity != null && !entity.action_replaced :
		if use_previous : 
			var previous = entity.prev_action;
			if previous == null : previous = entity.intended_action;
			
			if previous != null :
			
				entity.current_action = previous;
			
				# If the repeated action's targetting differs from the selection, randomize target
				if entity.current_action.spell_target != previous.spell_target:
					entity.set_target();
				
				entity.action_replaced = true;
			
		elif pick_random : 
			var actions = entity.move_list.duplicate();
			
			if entity is PlayerController:
				actions.append(entity.default_attack_action);
			
			var index = actions.find(entity.current_action);
			if index > -1:
				actions.remove_at(index);
			
			entity.current_action = actions.pick_random();
			entity.set_target();
			
			entity.action_replaced = true;
		
		elif action != null : 
			entity.current_action = action;
			entity.set_target();
			entity.action_replaced = true;
		
		if reset_sealing:
			entity.sealing = false;
