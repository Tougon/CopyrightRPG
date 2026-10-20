extends EffectFunction
class_name EFCheckHasMoved

@export var target : EffectFunction.Target;
@export var negate : bool = false;

func execute(instance : EffectInstance):
	var entity : EntityController;
	if target == Target.USER:
		entity = instance.user;
	elif target == Target.TARGET:
		entity = instance.target;
	
	if entity.is_defeated :
		instance.cast_success = false;
	
	if negate : 
		instance.cast_success = BattleScene.Instance.turn_order.has(entity);
	else :
		instance.cast_success = !BattleScene.Instance.turn_order.has(entity);
