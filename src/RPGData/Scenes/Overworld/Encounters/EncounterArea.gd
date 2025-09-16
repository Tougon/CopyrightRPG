extends EncounterManager

func _ready() :
	active = false;
	print("Init")
	super._ready();


func _on_body_entered(body: Node2D) -> void:
	if body is RPGPlayerController :
		active = true;
		print("Active")


func _on_body_exited(body: Node2D) -> void:
	if body is RPGPlayerController :
		active = false;
