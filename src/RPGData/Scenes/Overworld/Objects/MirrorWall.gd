extends Node2D

@export var offset := Vector2.ZERO;
@export_range(0, 0.1) var opacity_factor : float = 0.005;
@export var target_nodes : Array[Node2D];
@export var reflections : Array[Node2D];


func _ready() -> void:
	await get_tree().process_frame;
	
	for i in target_nodes.size() :
		var node = target_nodes[i];
		
		if node != null && i < reflections.size():
			var reflection = reflections[i];
			
			if node is RPGPlayerController :
				reflection.material = node.get_character_material();


func _process(delta: float) -> void:
	for i in target_nodes.size() :
		var node = target_nodes[i];
		
		if node != null && i < reflections.size():
			var y_dist = node.global_position.y - global_position.y;
			
			var reflection = reflections[i];
			reflection.global_position = Vector2(node.global_position.x, global_position.y - y_dist) + offset;
			
			reflection.modulate.a = 1.0 - (abs(y_dist) * opacity_factor);
			
			# TODO: Change reflection sprite based on direction
			
			# TODO: Copy ZLight parameters...oh god...
