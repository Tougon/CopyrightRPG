extends Node2D

@export var override_shape : Shape2D;
@export_file("*.tscn") var scene_path : String;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if override_shape != null :
		$CollisionShape2D.shape = override_shape;


func _on_body_entered(body: Node2D) -> void:
	if !can_process() || !is_visible_in_tree(): return;
	print(name);
	EventManager.load_scene.emit(scene_path);
