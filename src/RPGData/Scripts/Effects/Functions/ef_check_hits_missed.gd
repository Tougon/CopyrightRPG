extends EffectFunction
class_name EFCheckHitsMissed

enum CheckType { ANY, ALL }
@export var check_type : CheckType;
@export var check_hits : bool;
@export var ignore_subspells : bool;

func execute(instance : EffectInstance):
	var casts_to_check : Array[SpellCast];
	
	if instance.spell != null :
		casts_to_check.append(instance.spell);
	
	if instance.all_casts != null :
		for cast in instance.all_casts : 
			casts_to_check.append(cast);
	
	for cast in casts_to_check :
		var spell_miss = !cast.did_spell_hit();
		
		if check_type == CheckType.ANY :
			if spell_miss && !check_hits : 
				instance.cast_success = true;
				return;
			elif !spell_miss && check_hits :
				instance.cast_success = true;
				return;
		
		elif check_type == CheckType.ALL :
			if !spell_miss && !check_hits :
				instance.cast_success = false;
				return;
			elif spell_miss && check_hits :
				instance.cast_success = false;
				return;
		
		if !ignore_subspells && cast.subspell_casts != null :
			for subspell in cast.subspell_casts :
				var subspell_miss = !subspell.did_spell_hit();
				
				if check_type == CheckType.ANY :
					if subspell_miss && !check_hits :
						instance.cast_success = true;
						return;
					elif !subspell_miss && check_hits :
						instance.cast_success = true;
						return;
				
				elif check_type == CheckType.ALL :
					if !subspell_miss && !check_hits :
						instance.cast_success = false;
						return;
					elif subspell_miss && check_hits :
						instance.cast_success = false;
						return;
	
	instance.cast_success = check_type == CheckType.ALL;
