@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("TweenPlayerUI", "Node", preload("res://addons/toui/src/tween_player_ui.gd"), preload("res://addons/toui/icon.png"))


func _exit_tree():
	remove_custom_type("TweenPlayerUI")
