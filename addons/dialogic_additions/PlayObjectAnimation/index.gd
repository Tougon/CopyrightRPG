@tool
extends DialogicIndexer

func _get_events() -> Array:
	return [this_folder.path_join('event_play_object_animation.gd')]

