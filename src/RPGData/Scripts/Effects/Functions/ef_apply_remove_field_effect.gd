extends EffectFunction
class_name EFApplyRemoveFieldEffect

@export var field_effect : FieldEffect;
## If false, this command will instead remove this effect.
@export var apply : bool = true;

func execute(instance : EffectInstance):
	if apply : 
		BattleScene.Instance.apply_field_effect(field_effect);
	else :
		BattleScene.Instance.remove_field_effect(field_effect);
