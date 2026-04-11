extends Node2D

@export var offset := Vector2.ZERO;
@export var reflection_limit : float = 5.0;
@export_range(0, 0.1) var opacity_factor : float = 0.005;
@export var target_nodes : Array[Node2D];
@export var reflections : Array[Node2D];


func _ready() -> void:
	for reflection in reflections :
		reflection.modulate.a = 0.0;
	
	await get_tree().process_frame;
	
	for i in target_nodes.size() :
		var node = target_nodes[i];
		
		if node != null && i < reflections.size():
			var reflection = reflections[i];
			
			if node is RPGPlayerController :
				var frame = (node as RPGPlayerController)._player_visual.get_reflection_frame();
				reflection.global_position = node.global_position;
				reflection.texture = frame.frame_sprite;
				reflection.offset = frame.offset;
				reflection.material = node.get_character_material();
			
			reflection.modulate.a = 0.0;


func _process(delta: float) -> void:
	for i in target_nodes.size() :
		var node = target_nodes[i];
		
		if node != null && i < reflections.size():
			
			if node.global_position.y - reflection_limit  < global_position.y :
				reflections[i].modulate.a = 0.0;
			else :
				var y_dist = node.global_position.y - global_position.y;
				
				var reflection = reflections[i];
				reflection.global_position = Vector2(node.global_position.x, global_position.y - y_dist) + offset;
				
				reflection.modulate.a = 1.0 - (abs(y_dist) * opacity_factor);
				
				if node is RPGPlayerController :
					var frame = (node as RPGPlayerController)._player_visual.get_reflection_frame();
					reflection.texture = frame.frame_sprite;
					reflection.offset = frame.offset;
