extends Control
class_name UIBattleTargetInfo

var targets : Array[EntityController];
var arrows : Array[Control];
var player : EntityController;

@export var offset : Vector2 = Vector2(0, -50);

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func initialize(targets : Array[EntityController], arrows : Array[Control], player : EntityController):
	self.targets = targets;
	self.arrows = arrows;
	self.player = player;
	
	for i in arrows.size():
		arrows[i].visible = true;
		
		if i < targets.size():
			arrows[i].global_position = targets[i].global_position + offset;
		else:
			arrows[i].global_position = self.global_position + offset;
