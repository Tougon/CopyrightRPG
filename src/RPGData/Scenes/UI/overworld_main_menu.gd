extends MenuPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready();


func _on_save_pressed():
	DataManager.save_data();


func _on_load_pressed():
	DataManager.load_data();


func _on_delete_pressed():
	DataManager.delete_data();
