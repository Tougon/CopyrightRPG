extends EffectFunction
class_name EFReplaceDefaultSeal

@export var seal : SealEffectGroup;

func execute(instance : EffectInstance):
	var entity : EntityController = instance.user;
	
	if (entity != null && seal != null) :
		entity.seal_effect = seal;
