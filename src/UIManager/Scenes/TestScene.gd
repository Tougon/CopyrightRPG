extends Node2D

func _on_lower_button_pressed():
	UIManager.open_menu_name("Second");


func _on_upper_button_pressed():
	UIManager.close_menu_name("Second");
