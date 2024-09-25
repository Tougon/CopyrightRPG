extends Node

@export var enabled : bool = true;
@export var encounters : Array[Encounter];
# TODO: Perhaps we may make these const at some point?
@export var grace_period : float = 1.5;
@export_range(0, 1) var minimum_encounter_chance : float = 0.05;
@export_range(0, 1) var encounter_increase_rate : float = 0.05;
@export_range(0, 10) var encounter_reroll_rate : float = 1.0;

var current_chance : float = 0;
var encounter_chance : float = 0;
var wait_time : float = 0;
var encounter_time : float = 0;
var process_encounters : bool = true;

func _ready():
	EventManager.on_overworld_player_moved.connect(_on_overworld_player_moved);
	EventManager.on_battle_queue.connect(_reset_encounter_variables);
	EventManager.on_battle_end.connect(_on_battle_end);
	
	_reset_encounter_variables(null);


func _on_overworld_player_moved(direction : Vector2, amount : Vector2):
	if !enabled  || !process_encounters: return;
	
	var delta = get_process_delta_time();
	
	if wait_time < grace_period : 
		wait_time += delta;
	else :
		encounter_time += delta;
		
		if encounter_time >= encounter_reroll_rate:
			encounter_chance = randf();
			encounter_time = 0;
		
		if encounter_chance < current_chance:
			var encounter = _get_random_encounter();
			EventManager.on_battle_queue.emit(encounter);
			process_encounters = false;
		else:
			current_chance += (encounter_increase_rate * delta);


func _on_battle_end(result : BattleResult):
	process_encounters = true;


func _get_random_encounter() -> Encounter:
	if encounters.size() < 1 :
		print("ERROR: No encounters available. Returning null.");
		return null;
	
	var current = 0.0;
	var random = randf();
	print(random);
	
	for encounter in encounters:
		if encounter != null:
			current += encounter.odds;
			if random <= current: return encounter;
	
	if current != 1 : 
		print("NOTE: Probabilities are irregular. This may not be intended.")
	
	return encounters[encounters.size() - 1];


func _reset_encounter_variables(encounter : Encounter):
	wait_time = 0;
	encounter_time = 0;
	
	current_chance = minimum_encounter_chance;
	encounter_chance = randf();


func _exit_tree():
	if EventManager != null:
		EventManager.on_overworld_player_moved.disconnect(_on_overworld_player_moved);
		EventManager.on_battle_queue.disconnect(_reset_encounter_variables);
		EventManager.on_battle_end.disconnect(_on_battle_end);
