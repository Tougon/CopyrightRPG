extends AnimationSequenceAction

class_name ASAUpdateUI

enum UIType { HP, MP }
@export var target : Target;
@export var ui_type : UIType;

func execute(sequence : AnimationSequence):
	var entity : EntityBase;
	if target == Target.USER:
		entity = sequence.user;
	elif target == Target.TARGET:
		entity = sequence.target[sequence.target_index];
	
	if entity == null : return;
	
	if ui_type == UIType.HP:
		if entity.last_hit != 0:
			entity.update_hp_ui();
