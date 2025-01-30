@icon("node_name_label_icon.svg")
extends Label

class_name DialogicNode_NameLabel

# If true, the label will be hidden if no character speaks.
@export var hide_when_empty := true
@export var animate_visibility := false
@export var name_label_root: Node = self
@export var use_character_color := true

func _ready() -> void:
	add_to_group('dialogic_name_label')
	if hide_when_empty:
		if animate_visibility : name_label_root.scale = Vector2(0,1);
		else : name_label_root.visible = false
	text = ""


func _set(property, what):
	if property == 'text' and typeof(what) == TYPE_STRING:
		text = what
		if hide_when_empty:
			if animate_visibility : 
				name_label_root.visible = true
				# TODO: Don't hardcode it like this, we should be touching this anyway
				if !what.is_empty():
					var tween = get_tree().create_tween();
					tween.tween_property(name_label_root, "scale", Vector2(1,1), 0.25).set_ease(Tween.EASE_OUT).set_delay(0.25)
				else : 
					var tween = get_tree().create_tween();
					tween.tween_property(name_label_root, "scale", Vector2(0,1), 0.25).set_ease(Tween.EASE_OUT);
			else : name_label_root.visible = !what.is_empty()
		else:
			name_label_root.show()
		return true
