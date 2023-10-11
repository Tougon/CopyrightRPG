@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("TweenPlayer", "Node", preload("res://addons/totween/src/tween_player.gd"), preload("res://addons/totween/icon.png"))


func _exit_tree():
	remove_custom_type("TweenPlayer")
