extends Button
class_name UIBattleTargetInfo

var targets : Array[EntityController];
var arrows : Array[Control];
var player : EntityController;

var all : bool = false;
var selected : bool = false;

@export var offset : Vector2 = Vector2(0, -50);

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func initialize(targets : Array[EntityController], arrows : Array[Control], player : EntityController, all : bool):
	self.targets = targets;
	self.arrows = arrows;
	self.player = player;
	self.all = all;
	
	for i in arrows.size():
		if i < targets.size():
			arrows[i].global_position = targets[i].global_position + offset - (arrows[i].size / 2) + targets[i].get_sprite_top_offset();
		else:
			arrows[i].global_position = self.global_position + offset - (arrows[i].size / 2)
			

func _on_focus_entered():
	if targets.size() <= 0:
		return;
	
	selected = true;
	EventManager.highlight_target.emit(targets[0], all);
	
	for i in arrows.size():
		arrows[i].visible = true;
		arrows[i].get_node("TweenPlayerUI").play_tween_name("Arrow Bob");
	
	for target in targets:
		if target != null : 
			target.mat.set_shader_parameter("overlay_color", Color.WHITE);
			target.tween.play_tween_name("Entity Highlight");


func _on_focus_exited():
	selected = false;
	
	for i in arrows.size():
		arrows[i].get_node("TweenPlayerUI").cancel_tween();
		arrows[i].visible = false;
	
	for target in targets:
		if target != null : 
			target.tween.play_tween_name("Entity Highlight End");


func _on_pressed():
	select_target();


func select_target():
	player.current_target = targets;
	player.is_ready = true;
