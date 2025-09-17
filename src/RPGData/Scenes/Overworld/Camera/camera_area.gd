extends Node2D


func _on_body_entered(body: Node2D) -> void:
	if !(body is RPGPlayerController) : return;
	
	while (OverworldManager.game_camera == null) :
		await get_tree().process_frame;
	
	#OverworldManager.game_camera.limit_target = "";
	#OverworldManager.game_camera.limit_target = OverworldManager.game_camera.get_path_to($Collision/CollisionShape2D)
	print("Setting to..." + name)
