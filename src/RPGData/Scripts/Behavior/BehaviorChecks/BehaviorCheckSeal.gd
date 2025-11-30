extends BehaviorCheck

class_name BehaviorCheckSeal

@export var move_id : int;
@export var check_player_side : bool = true;
@export_range(0, 1) var chance_if_sealed : float = 1.0;
@export var weigh_seal_count : bool = false;
@export_range(0, 9) var caution_threshold : int = 0;
@export var weight : Curve;
@export var result_if_zero : bool = true;


func check(user : EntityController, allies : Array[EntityController], targets : Array[EntityController], result : BehaviorCheckResult) -> bool:
	
	if user.move_list.size() < move_id:
		return false;
	
	var seal_count = 0;
	
	if move_id >= 0 : seal_count = BattleScene.Instance.seal_manager.get_seal_overlap_count(user.move_list[move_id], check_player_side);
	else : seal_count = BattleScene.Instance.seal_manager.get_player_seal_count();
	
	if seal_count == 0 : return result_if_zero;
	
	var rand_chance = randf();
	var caution = 1;
	
	if weigh_seal_count : 
		var caution_divisor = 10 - caution_threshold;
		caution = weight.sample((seal_count as float) / (caution_divisor as float));
		
		# If caution reaches 0, then the move will never be used
		if caution <= 0 : return !negate;
	
	var seal_check = rand_chance < (chance_if_sealed * caution);
	
	if negate : return !seal_check;
	else : return seal_check;
	
	return false;
