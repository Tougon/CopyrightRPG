extends Sequence

class_name AnimationSequence

var initialized : bool;
var running : bool;
var looping : bool;
var on_success : bool;

var target_index : int;
var current_frame : int;
var loop : int;

var current_time : float;
var direction_x : float;
var direction_y : float;

var sequence_name : String;

var user : EntityController;
var target : Array[EntityController];

var spell_cast : Array[SpellCast];
var aso : AnimationSequenceObject;

# Initial Values
var user_position : Vector2;
var target_position : Array[Vector2];
var user_rotation : float;
var target_rotation : Array[float];
var user_scale : Vector2;
var target_scale : Array[Vector2];
var user_color : Color;
var target_color : Array[Color];
var user_amount : float;
var target_amount : Array[float];
#

var user_sprite : Sprite2D;
var target_sprite : Array[Sprite2D];

var effects : Array[EntityBase];

var loops : Array[AnimationSequenceLoop];


func _init(in_tree : SceneTree, obj : AnimationSequenceObject, u : EntityController, t : Array[EntityController], s : Array[SpellCast]):
	target = t;
	init_sequence(obj, u);
	
	spell_cast = s;
	
	if spell_cast != null : 
		for spell in spell_cast:
			if spell.get_number_of_hits() > loop : 
				loop = spell.get_number_of_hits();
	
	super._init(in_tree);


func init_sequence(obj : AnimationSequenceObject, u : EntityController):
	aso = obj;
	user = u;
	
	user_position = user.position;
	user_rotation = user.rotation;
	user_scale = user.scale;
	user_sprite = user.sprite;
	user_color = user_sprite.modulate;
	user_amount = user.mat.get_shader_parameter("overlay_color_amount");
	
	direction_x = user.scale.x / abs(user.scale.x);
	direction_y = user.scale.y / abs(user.scale.y);
	
	if target != null:
		for t in target:
			target_position.append(t.position);
			target_rotation.append(t.rotation);
			target_scale.append(t.scale);
			target_sprite.append(t.sprite);
			target_color.append(t.sprite.modulate);
			target_amount.append(t.mat.get_shader_parameter("overlay_color_amount"));
	
	initialized = true;


func sequence_start():
	active = true;
	running = true;
	
	super.sequence_start();
	
	# TODO: Disable UI calls


func sequence_loop():
	while running:
		current_time += user.get_process_delta_time();
		
		if current_time >= (1.0 / 60.0):
			var num_frames = (int)(current_time / (1.0 / 60.0))
			
			for i in num_frames:
				current_frame += 1;
				
				for frame in aso.animation_sequence:
					if frame.frame == current_frame:
						call_sequence_function(frame.action);
			
			current_time -= (num_frames * (1.0 / 60.0))
		
		await tree.process_frame;
	
	sequence_end();
	active = false;


func sequence_end():
	print("Animation End")
	while effects.size() > 0:
		effects[0].queue_free();
		effects.remove_at(0);
	
	user.position = user_position;
	user.rotation = user_rotation;
	user.scale = user_scale;
	user_sprite.modulate = user_color;
	user.mat.set_shader_parameter("overlay_color_amount", user_amount);
	
	for i in target.size():
		target[i].position = target_position[i];
		target[i].rotation = target_rotation[i];
		target[i].scale = target_scale[i];
		target_sprite[i].modulate = target_color[i];
		target[i].mat.set_shader_parameter("overlay_color_amount", target_amount[i]);
	
	super.sequence_end();


func call_sequence_function(action : AnimationSequenceAction):
	
	if on_success && !action.ignore_on_success() && !spell_cast[target_index].has_spell_done_anything():
		return;
	
	action.execute(self);
