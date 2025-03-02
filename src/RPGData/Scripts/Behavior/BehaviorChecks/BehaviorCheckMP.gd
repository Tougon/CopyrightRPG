extends BehaviorCheck

class_name BehaviorCheckMP

enum CheckMPType {MoveID, Amount, Percentage}

@export var check_type : CheckMPType;
@export var move_id : int;
@export var mp_amount : int;
@export_range(0, 1) var mp_percent : float;

func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	
	if check_target == CheckTarget.Self:
		result.trigger_entity = user;
		
		match check_type:
			CheckMPType.MoveID :
				if user.move_list.size() < move_id:
					return false;
				
				var move_mp = user.move_list[move_id].spell_cost;
				var move_check = user.current_mp >= move_mp;
				
				if negate:
					return !move_check;
				else:
					return move_check;
			
			CheckMPType.Amount :
				var amount_check = user.current_mp >= mp_amount;
				
				if negate:
					return !amount_check;
				else:
					return amount_check;
			
			CheckMPType.Percentage :
				var percent_check = user.get_mp_percent() >= mp_percent;
				
				if negate:
					return !percent_check;
				else:
					return percent_check;
	else:
		var check_ec = targets;
		
		if check_target == CheckTarget.Allies:
			check_ec = allies;
		
		for ec in check_ec:
			var percent_check = ec.get_mp_percent() >= mp_percent;
			var val = false;
			
			if negate:
				val = !percent_check;
			else:
				val = percent_check;
			
			if val:
				result.trigger_entity = ec;
				return true;
		
	return false;
