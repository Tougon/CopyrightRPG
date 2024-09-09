extends Node2D
class_name EntityBase

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Entity specific initialization
func entity_init(params : BattleParams):
	pass


# Visual control
func set_entity_sprite(sprite : Texture2D):
	pass;


func set_overlay_sprite(sprite : Texture2D):
	pass;


func get_entity_material():
	return null;


# Animation control
func set_animation(val : String):
	pass;


func frame_speed_modify(speed : float):
	pass;


# Tween control
func set_color_tween(color_tween: TweenFrame, amt_tween: TweenFrame):
	pass;


func set_overlay_tween(offset_tween: TweenFrame, tiling_tween: TweenFrame, amt_tween: TweenFrame):
	pass;
