extends Node2D

class_name TAnimationPlayer;

@export var animation : Spell;
@export var dummy_player : Entity
@export var dummy_enemy : Entity
@export var entity_controllers : Array[EntityController];
@export var isolated_scene : bool = true;

var player : PlayerController;
var ally : PlayerController;
var enemies : Array[EntityController];

var test_attack : bool = false;
var target_ally : bool = false;
var is_attacking : bool = false;
var hit : bool = true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !isolated_scene : return;
	
	initialize_animation(animation, dummy_player, dummy_player, dummy_enemy);


func initialize_animation(action : Spell, new_player : Entity, new_ally : Entity, new_target : Entity) :
	animation = action;
	player = null;
	ally = null;
	enemies.clear();
	
	var fake_battle = BattleParams.new();
	
	var player_data = BattleParamEntity.new();
	player_data.id = 0;
	player_data.override_level = 1;
	player_data.override_entity = new_player;
	
	fake_battle.players.append(player_data)
	
	# Need support for multiple allies, add this when it's working, test with CHECK PLUS
	if _add_single_ally() :
		var ally_data = BattleParamEntity.new();
		ally_data.id = 1;
		ally_data.override_level = 1;
		ally_data.override_entity = new_ally;
		
		fake_battle.players.append(ally_data);
		
		target_ally = true;
	else :
		target_ally = false;
	
	
	# Number of enemies to add depends on move type
	#if _add_single_enemy() :
	fake_battle.enemies.append(dummy_enemy);
	if _add_multiple_enemy() :
		fake_battle.enemies.append(dummy_enemy);
		fake_battle.enemies.append(dummy_enemy);
	
	for controller in entity_controllers:
		controller.entity_init(fake_battle);
		
		if controller is PlayerController :
			if player == null : 
				player = controller;
			else : 
				ally = controller;
		elif controller is EnemyController :
			enemies.append(controller);
	
	# Uncouple this Please.
	EventManager.on_battle_begin.emit(fake_battle);
	
	# Don't play the audio when called elsewhere
	if isolated_scene :
		EventManager.load_aux_audio.emit(animation.spell_sfx);
	
	$"Background/BG Video Canvas"._load_spell_data(animation);
	
	# Maybe we want this to hide loads?
	await get_tree().create_timer(1.0).timeout
	
	if !isolated_scene : test_attack = true;
	
	if test_attack : 
		# NOTE: we'll need to add a force kill option.
		play_animation();


func _add_single_ally() -> bool :
	if animation.spell_target == Spell.SpellTarget.SingleParty :
		return true;
	else : return false;


func _add_multiple_ally() -> bool :
	if animation.spell_target == Spell.SpellTarget.All || animation.spell_target == Spell.SpellTarget.AllParty :
		return true;
	else : return false;


func _add_single_enemy() -> bool :
	if animation.spell_target == Spell.SpellTarget.SingleEnemy :
		return true;
	else : return false;


func _add_multiple_enemy() -> bool :
	if animation.spell_target == Spell.SpellTarget.RandomEnemy || animation.spell_target == Spell.SpellTarget.RandomEnemyPerHit || animation.spell_target == Spell.SpellTarget.AllEnemy || animation.spell_target == Spell.SpellTarget.All :
		return true;
	else : return false;


func _process(_delta: float) -> void:
	if isolated_scene && Input.is_action_just_pressed("pause"):
		if !test_attack && !is_attacking :
			hit = true;
			play_animation();
		
		test_attack = !test_attack;
		
		if !test_attack :
			stop_animation();


func stop_animation():
	test_attack = false;
	$Core/Sequencer.terminate_all();


func play_animation():
	is_attacking = true;
	player.current_action = animation;
	
	# Restore MP and HP to prevent silly fail states
	player.modify_mp(999);
	
	for enemy in enemies:
		enemy.apply_damage(-9999, false, false, true, 0, 0, 0, 0.35, false);
	
	# Cast the spell
	var spell_cast : Array[SpellCast];
	if target_ally : 
		player.enemies = [ ally ];
		spell_cast = player.current_action.cast(player, player.enemies);
	else : 
		player.enemies = enemies;
		spell_cast = player.current_action.cast(player, player.enemies);
	
	# Rig the damage roll to do 1 damage (this is so we can debug UI timing)
	for cast in spell_cast:
		cast.success = true;
		
		for i in cast.damage.size():
			if self.hit : 
				cast.damage[i] = 1;
			else :
				cast.damage[i] = 0;
			
			if animation is DamageSpell && animation.negate :
				cast.damage[i] *= -1;
		
		if self.hit : 
			cast.total_damage = 1 * cast.damage.size();
		else :
			cast.total_damage = 0;
		
		if animation is DamageSpell && animation.negate :
			cast.total_damage *= -1
		
		for i in cast.hits.size():
			cast.hits[i] = self.hit;
		
		cast.critical = false;
		for i in cast.critical_hits.size():
			cast.critical_hits[i] = false;
	
	player.action_result = spell_cast;
	
	if target_ally : 
		var animation_seq = AnimationSequence.new(get_tree(), animation.animation_sequence, player, [ally], spell_cast);
		$Core/Sequencer._on_sequence_queue(animation_seq);
		await animation_seq.sequence_ended;
	else : 
		var animation_seq = AnimationSequence.new(get_tree(), animation.animation_sequence, player, enemies, spell_cast);
		$Core/Sequencer._on_sequence_queue(animation_seq);
		await animation_seq.sequence_ended;
	
	is_attacking = false;
	
	if isolated_scene :
		self.hit = !hit;
	
	await get_tree().create_timer(1.0).timeout
	
	if (test_attack && !is_attacking) :
		play_animation();
