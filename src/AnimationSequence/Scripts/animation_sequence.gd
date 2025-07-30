extends Sequence

class_name AnimationSequence

var initialized : bool;
var running : bool;
var looping : bool;
var on_success : bool;
var check_miss : bool;
var applied_damage_this_frame : bool;

var target_index : int;
var current_frame : int;
var current_action_index : int;
var loop_hits : int;
var loop_targets : int;

var current_time : float;
var direction_x : float;
var direction_y : float;

var sequence_name : String;

var root : Node;
var user : EntityController;
var target : Array[EntityController];

var spell_data : Spell;
var spell_cast : Array[SpellCast];
var aso : AnimationSequenceObject;

# Initial Values
var user_position : Vector2;
var target_position : Array[Vector2];
var user_sprite_position : Vector2;
var target_sprite_position : Array[Vector2];
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
			if spell == null : continue;
			if spell.spell != null : 
				spell_data = spell.spell;
			if spell.get_number_of_hits() > loop_hits : 
				loop_hits = spell.get_number_of_hits();
	
	if spell_data != null && spell_data.spell_target == Spell.SpellTarget.RandomEnemyPerHit :
		loop_targets = 1;
	else : loop_targets = target.size();
	
	for frame in aso.animation_sequence:
		frame.action.warmup();
	
	super._init(in_tree);


func init_sequence(obj : AnimationSequenceObject, u : EntityController):
	aso = obj;
	user = u;
	root = u.get_parent();
	
	user_position = user.position;
	user_rotation = user.rotation;
	user_scale = user.scale;
	user_sprite = user.sprite;
	if user_sprite != null : user_sprite_position = user.sprite.position;
	user_color = user_sprite.modulate;
	user_amount = user.mat.get_shader_parameter("overlay_color_amount");
	
	direction_x = user.scale.x / abs(user.scale.x);
	direction_y = user.scale.y / abs(user.scale.y);
	
	if user.use_override_direction :
		direction_x = user.override_direction.x / abs(user.override_direction.x);
		direction_y = user.override_direction.y / abs(user.override_direction.y);
	
	if target != null:
		for t in target:
			target_position.append(t.position);
			target_rotation.append(t.rotation);
			target_scale.append(t.scale);
			target_sprite.append(t.sprite);
			if t.sprite : target_sprite_position.append(t.sprite.position);
			else : target_sprite_position.append(Vector2(0, 0));
			target_color.append(t.sprite.modulate);
			target_amount.append(t.mat.get_shader_parameter("overlay_color_amount"));
	
	initialized = true;


func sequence_start():
	active = true;
	running = true;
	
	super.sequence_start();
	
	if aso != null && aso.hide_ui_on_start :
		EventManager.hide_entity_ui.emit();


func sequence_loop():
	# If there is no sequence, immediately end, operation is unneeded.
	if aso == null || aso.animation_sequence == null: 
		sequence_end();
		active = false;
		return;
	
	while running:
		current_time += user.get_process_delta_time();
		
		if current_time >= (1.0 / 60.0):
			var num_frames = (int)(current_time / (1.0 / 60.0))
			
			for i in num_frames:
				current_frame += 1;
				applied_damage_this_frame = false;
				
				# NOTE: Frame Order is not acknowledged.
				# With Godot's workflow, this isn't a huge concern, but is notable.
				current_action_index = 0;
				
				while current_action_index < aso.animation_sequence.size():
					var frame = aso.animation_sequence[current_action_index];
					if frame.frame == current_frame:
						call_sequence_function(frame.action);
					current_action_index += 1;
					
				#for frame in aso.animation_sequence:
				#	if frame.frame == current_frame:
				#		call_sequence_function(frame.action);
			
			current_time -= (num_frames * (1.0 / 60.0))
		
		await tree.process_frame;
	
	sequence_end();
	active = false;


func kill():
	running = false;
	sequence_end();
	active = false;


func sequence_end():
	while effects.size() > 0:
		effects[0].queue_free();
		effects.remove_at(0);
		
	await tree.process_frame;
	
	user.position = user_position;
	user.rotation = user_rotation;
	user.scale = user_scale;
	if user_sprite != null : 
		user_sprite.modulate = user_color;
		user_sprite.position = user_sprite_position;
	user.mat.set_shader_parameter("overlay_color_amount", user_amount);
	user.mat.set_shader_parameter("alpha_amount", 0);
	
	for i in target.size():
		target[i].position = target_position[i];
		target[i].rotation = target_rotation[i];
		target[i].scale = target_scale[i];
		if target_sprite[i] != null:
			target_sprite[i].modulate = target_color[i];
			target_sprite[i].position = target_sprite_position[i];
		target[i].mat.set_shader_parameter("overlay_color_amount", target_amount[i]);
		target[i].mat.set_shader_parameter("alpha_amount", 0);
	
	for frame in aso.animation_sequence:
		frame.action.cooldown();
	
	super.sequence_end();


func call_sequence_function(action : AnimationSequenceAction):
	var index = target_index;
	if spell_data && spell_data.spell_target == Spell.SpellTarget.RandomEnemyPerHit :
		index = 0;
	
	var cast_inst : SpellCast = null;
	if target_index < spell_cast.size():
		cast_inst = spell_cast[target_index];
	
	var hit_index = 0;
	if cast_inst != null : hit_index = cast_inst.current_hit; 
	if applied_damage_this_frame : hit_index -= 1;
	
	if ((on_success && !cast_inst.has_spell_done_anything()) || (check_miss && !cast_inst.get_hit_success(hit_index))) && !action.ignore_on_success() :
		return;
	
	action.execute(self);
