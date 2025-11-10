extends EffectFunction
class_name EFChangeTarget

@export var target : EffectFunction.Target;
@export var use_previous : bool = false;
@export var override_intended_target : bool = false;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	var action = entity.current_action;
	
	if action != null:
		if use_previous : 
			entity.current_target = entity.prev_target;
		
		else :
			var targets = entity.get_possible_targets(action);
			for t in entity.current_target :
				var index = targets.find(t);
				if index > -1:
					targets.remove_at(index);
			
			if targets.size() > 0 :
				entity.current_target = [targets.pick_random()];
		
		if override_intended_target : 
			entity.intended_target = entity.current_target.duplicate();
