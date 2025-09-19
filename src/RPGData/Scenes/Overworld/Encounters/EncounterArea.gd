extends EncounterManager

func _ready() :
	active = false;
	super._ready();


func _on_body_entered(body: Node2D) -> void:
	if body is RPGPlayerController :
		active = true;


func _on_body_exited(body: Node2D) -> void:
	if body is RPGPlayerController :
		active = false;
