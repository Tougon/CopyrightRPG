extends EffectFunction
class_name EFCheckNumHits

@export var num_hits : int = 5;
@export var check_mode : EffectFunction.CheckMode;

func execute(instance : EffectInstance):
	var casts_to_check : Array[SpellCast];
	var hits : int = 0;
	
	if instance.spell != null :
		casts_to_check.append(instance.spell);
	
	if instance.all_casts != null :
		for cast in instance.all_casts : 
			casts_to_check.append(cast);
	
	for cast in casts_to_check :
		for hit in cast.hits :
			if hit : 
				hits += 1;
	
	print(hits);
	match check_mode :
		EffectFunction.CheckMode.EQUALS:
			instance.cast_success = hits == num_hits;
		
		EffectFunction.CheckMode.GREATER:
			instance.cast_success = hits > num_hits;
		
		EffectFunction.CheckMode.GREATEREQUAL:
			instance.cast_success = hits >= num_hits;
		
		EffectFunction.CheckMode.LESS:
			instance.cast_success = hits < num_hits;
		
		EffectFunction.CheckMode.LESSEQUAL:
			instance.cast_success = hits <= num_hits;
