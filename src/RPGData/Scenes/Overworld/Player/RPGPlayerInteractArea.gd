extends Area2D

var interactions : Array[Interactable];
var closest_interactable : Interactable;
var reference_node : Node2D;

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	area_exited.connect(_on_area_exited)
	body_exited.connect(_on_body_exited)


func _on_area_entered(area : Area2D):
	_add_node_to_list(area.get_parent())


func _on_body_entered(body : Node2D):
	_add_node_to_list(body.get_parent())


func _on_area_exited(area : Area2D):
	_remove_node_from_list(area.get_parent())


func _on_body_exited(body : Node2D):
	_remove_node_from_list(body.get_parent())


func _add_node_to_list(node : Node):
	if node != null && node is Interactable:
		interactions.append(node as Interactable);
		_calculate_closest_interactable();


func _remove_node_from_list(node : Node):
	if node != null && node is Interactable:
		interactions.erase(node as Interactable);
		_calculate_closest_interactable();


func _calculate_closest_interactable():
	var prev_closest = closest_interactable;
	closest_interactable = null;
	
	var relative_pos = global_position;
	if reference_node != null : relative_pos = reference_node.global_position;
	
	# For some reason, Godot does not support max for float
	var distance = 1000000000;
	
	for obj in interactions:
		var dist = obj.collision_root.global_position.distance_to(relative_pos);
		if  dist < distance:
			closest_interactable = obj;
			distance = dist;
	
	if prev_closest != closest_interactable:
		if prev_closest != null: prev_closest.highlight(false);
		if closest_interactable != null: closest_interactable.highlight(true);
