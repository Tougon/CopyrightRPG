extends Node
class_name SealManager

const SEAL_TURN_COUNT : int = 4;
const MAX_SEALS_PER_SIDE : int = 4;

var seal_instances : Array[SealInstance];
var sealed_spells : Array[Spell];

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.on_battle_begin.connect(_on_battle_begin);


func _on_battle_begin():
	seal_instances = [];
	sealed_spells = [];


func can_seal_spell(spell : Spell) -> bool:
	return !sealed_spells.has(spell);


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_begin.disconnect(_on_battle_begin);
