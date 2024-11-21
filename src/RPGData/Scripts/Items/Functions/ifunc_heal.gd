extends ItemFunction

class_name IFuncHeal

@export var target : Target;
@export_range(0, 9999) var heal_amt : int = 40;
@export var percent_heal : bool = false;
@export_range(0, 1) var percent_heal_amt : float = 0.5;
@export var negate : bool = false;

func execute_overworld(target : int):
	pass;

func execute_battle(user : EntityController, target : EntityController):
	var entity : EntityController;
	if self.target == Target.USER: entity = user
	elif self.target == Target.TARGET: entity = target;
	
	if entity != null:
		var amt = heal_amt;
		var before = entity.current_hp;
		
		if percent_heal : amt = roundi(float(entity.max_hp) * percent_heal_amt);
		if !negate : amt *= -1;
		entity.apply_damage(amt, false, negate, negate);
		
		if entity.current_hp - before != 0:
			entity.update_hp_ui();
