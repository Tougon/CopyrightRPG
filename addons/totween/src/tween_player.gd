extends Node

class_name TweenPlayer

@export var sequence_list: Array[TweenResourceInstance];

signal tween_ended(string_name);

# Runtime only
var sequences = {};
var current_tween : Tween;
var next_tween : String = "";
var current_resource : TweenResource;
var current_resource_instance : TweenResourceInstance;


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add all tweens into the runtime lookup list
	for sequence in sequence_list:
		
		if sequences.has(sequence.tween_name): continue;
		
		sequences[sequence.tween_name] = sequence;
		
		# Play this sequence immediately if it should be played on start
		if sequence.play_on_start:
			_play_tween_instance(sequence);

func add_tween_runtime(sequence : TweenResourceInstance):
	if !sequences.has(sequence.tween_name):
		sequences[sequence.tween_name] = sequence;

func play_tween_name(name: String):
	if sequences.has(name) : _play_tween_instance(sequences[name]);


func _play_tween_instance(tween: TweenResourceInstance):
	_reset_tween_state();
	current_resource_instance = tween;
	_play_tween(tween.tween_resource);


# Plays a tween from a provided resource.
func _play_tween(tween: TweenResource):
	
	if get_tree() == null : 
		return;
		
	# Cancel the current tween
	if current_tween != null && current_tween.is_running():
		current_tween.kill();
		current_tween = null;
	
	# Create the tween and set its movement to parallel
	current_resource = tween;
	current_tween = get_tree().create_tween();
	current_tween.set_parallel(true);
	
	# Prepare a running total for the delay
	var delay: float = 0;
	
	# Iterate through each group in the sequence
	for group_id in tween.sequence.size():
		# Cache the group for future operation
		var group = tween.sequence[group_id];
		
		# Iterate through each frame in the group
		for frame_id in group.frames.size():
			# Cache the frame for future operation
			var frame = group.frames[frame_id];
			
			# Get the target
			var target = get_node(NodePath(frame.get_relative_target()));
			
			# Check if the target is valid. If so, add this frame to the tween
			if target == null:
				continue;
			else:
				if frame.material_property:
					target = target.material;
				
				var property = current_tween.tween_property(target, frame.property_name, frame.get_value(), frame.duration);
				property.set_trans(frame.transition)
				property.set_ease(frame.ease)
				property.set_delay(delay + frame.delay);
				
				if frame.relative:
					property.as_relative();
				
				if frame.use_from:
					property.from(frame.get_value_from());
		
		# Increase the delay for the next group
		delay += group.get_longest_tween_duration();
	
	# Add callback
	current_tween.tween_callback(_on_tween_complete).set_delay(delay);


func _on_tween_complete():
	# Cache the next tween and reset it
	var next = next_tween;
	next_tween = "";
	
	# Check if resource instance is valid
	if current_resource_instance != null:
		tween_ended.emit(current_resource_instance.tween_name);
		
		# Run next tween according to the current instance
		if next != "":
			play_tween_name(next);
		else :
			play_tween_name(current_resource_instance.next_tween);
		
	# Check if resource is valid
	elif current_resource != null:
		tween_ended.emit(current_resource.resource_name);
		
		if next != "":
			play_tween_name(next);
		
	else:
		tween_ended.emit("unknown");
		
		if next != "":
			play_tween_name(next);


func cancel_tween():
	_reset_tween_state();


func _reset_tween_state():
	next_tween = "";
	
	if current_tween != null && current_tween.is_running():
		current_tween.kill();
	
	current_resource_instance = null;
	current_resource = null;
	current_tween = null;


func has_tween(name: String):
	return sequences.has(name);
