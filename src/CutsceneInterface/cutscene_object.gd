extends Node2D
class_name CutsceneObject

# Identifier used to access this object for the purpose of cutscenes
@export var object_id : String;
@export var tween_player : TweenPlayer;
@export var animation_player : AnimationPlayer;


func _ready() -> void:
	CutsceneObjectManager.add_object(self);


func set_object_active(active : bool):
	self.visible = active;


func _exit_tree() -> void:
	CutsceneObjectManager.remove_object(self);
