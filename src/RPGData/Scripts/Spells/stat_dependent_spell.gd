@tool
extends DamageSpell
class_name StatDependentSpell

# Override that will likely only be used for Spell C02.
# Maybe there's a chance this will be expanded more later, but I doubt it.
@export var exclude_self_buffs : bool = true;

func check_spell_power(user : EntityController, target : EntityController) -> float :
	var allies = user.allies;
	var multiplier = 1;
	
	for ally in allies :
		if ally == user && exclude_self_buffs : continue;
		
		var atk = ally.atk_stage;
		var def = ally.def_stage;
		var mag = ally.sp_atk_stage;
		var res = ally.sp_def_stage;
		var spd = ally.spd_stage;
		
		if atk > 0 : multiplier += atk;
		if def > 0 : multiplier += def;
		if mag > 0 : multiplier += mag;
		if res > 0 : multiplier += res;
		if spd > 0 : multiplier += spd;
	
	return spell_power * multiplier;
