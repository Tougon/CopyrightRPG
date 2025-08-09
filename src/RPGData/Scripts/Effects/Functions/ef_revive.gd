extends EffectFunction
class_name EFRevive

@export var target : EffectFunction.Target;
@export_range(0, 1) var hp_percent : float = 0.5;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity != null :
		var hp = roundi((entity.max_hp as float) * hp_percent)
		entity.revive(hp);
