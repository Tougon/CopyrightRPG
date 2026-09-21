extends Node
class_name SealManager

@export var seal_vfx : Array[SealData];

const SEAL_TURN_COUNT : int = 4;
const MAX_SEALS_PER_SIDE : int = 4;

var seal_instances : Array[SealInstance];
var sealed_spells : Array[Spell];
var enemy_sealed_spells : Dictionary;


# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.on_battle_begin.connect(_on_battle_begin);
	EventManager.on_entity_defeated.connect(_on_entity_defeated);
	EventManager.on_entity_turn_end.connect(_on_entity_turn_end);
	
	if BattleManager.seal_manager == null:
		BattleManager.seal_manager = self;


func _on_battle_begin(params : BattleParams):
	seal_instances = [];
	sealed_spells = [];


func _on_entity_defeated(entity : EntityController):
	var index = 0;
	
	var output_msg = false;
	
	for ally in entity.allies :
		if !ally.is_defeated : 
			output_msg = true;
			break;
	
	while index < seal_instances.size() && seal_instances.size() > 0:
		var seal = seal_instances[index];
		
		if seal.seal_entity == entity:
			# Send a message saying the seal has been lifted
			# NOTE: Only runs once so we don't output excessive messages
			if output_msg :
				#_send_seal_inactive_message(seal, entity);
				_send_seal_inactive_message(seal, entity, "T_BATTLE_ACTION_SEAL_INACTIVE_ALL");
				output_msg = false;
			
			seal_instances[index].free();
			seal_instances.remove_at(index);
		else :
			index += 1;


func _send_seal_inactive_message(seal : SealInstance, entity : EntityController, msg : String = "T_BATTLE_ACTION_SEAL_INACTIVE"):
	var seal_msg = tr(msg);
	var seal_entity_name = "[color=FFFF00]" + seal.seal_entity.param.entity_name + "[/color]"
	var entity_name = "[color=FFFF00]" + entity.param.entity_name + "[/color]"
	var action_name = "";
	
	if seal.seal_entity.current_entity.generic && BattleScene.Instance.enemy_type_count[seal.seal_entity.current_entity] && BattleScene.Instance.enemy_type_count[seal.seal_entity.current_entity] <= 1:
		seal_msg = seal_msg.format({ article_def = GrammarManager.get_direct_article(seal.seal_entity.param.entity_name), entity = seal_entity_name });
	else:
		seal_msg = seal_msg.format({ article_def = "", entity = seal_entity_name });
	
	if entity.current_entity.generic && BattleScene.Instance.enemy_type_count[entity.current_entity] && BattleScene.Instance.enemy_type_count[entity.current_entity] <= 1:
		seal_msg = seal_msg.format({ t_article_def = GrammarManager.get_direct_article(entity.param.entity_name), t_entity = entity_name });
	else: 
		seal_msg = seal_msg.format({ t_article_def = "", t_entity = entity_name });
	
	if seal.seal_source.spell_name_key.is_empty() :
		action_name = tr("T_SPELL_GENERIC_PRONOUN");
		action_name = action_name.format({ pronoun3 = GrammarManager.get_pronoun(entity.param.entity_gender, 3) })
	else :
		action_name = tr(seal.seal_source.spell_name_key);
	
	seal_msg = seal_msg.format({ action = action_name });
	EventManager.on_dialogue_queue.emit(seal_msg);


func can_seal_spell(spell : Spell, entity : EntityController) -> bool:
	# Some Entity Behaviors may cause an attempted seal on Nothing
	# Don't bother with these, they should never be allowed to seal.
	if spell.spell_flags.size() <= 0 : return false;
	
	if BattleManager.ENEMY_SEAL_ALL_UNIQUE && entity is EnemyController :
		if enemy_sealed_spells.has(entity) :
			return !enemy_sealed_spells[entity].has(spell);
		else :
			return true;
	
	return !sealed_spells.has(spell);


func _get_seal_effect_group(spell : Spell) -> SealEffectGroup:
	if spell.spell_flags.size() < 1 : return null;
	
	var primary_flag = spell.spell_flags[0];
	
	for seal in seal_vfx:
		if seal.flag == primary_flag :
			return seal.effect;
	
	return null;


func create_seal_instance(entity : EntityController, spell : Spell, player_side : bool):
	var turn_count : int = SEAL_TURN_COUNT;
	
	var effect = _get_seal_effect_group(spell);
	
	if (effect == null) : return;
	
	# We need to add an extra turn because otherwise the turn it's active counts
	# This effectively means 3 turns is 2.
	if BattleManager.seal_before_attacking : turn_count += 1;
	if effect.override_turn_count : turn_count = effect.turn_count;
	
	var seal_inst = SealInstance.new(entity, spell, effect, turn_count, player_side);
	seal_instances.append(seal_inst);
	
	# Add spell to the sealed list
	if BattleManager.ENEMY_SEAL_ALL_UNIQUE && entity is EnemyController :
		if !enemy_sealed_spells.has(entity) :
			enemy_sealed_spells[entity] = [];
		enemy_sealed_spells[entity].append(spell);
	else :
		sealed_spells.append(spell);
	
	for flag in spell.spell_flags :
		_play_seal_effects(seal_inst, entity, flag);
		await get_tree().create_timer(0.3).timeout;
	
	_play_seal_effects(seal_inst, entity, spell.spell_kind);
	await get_tree().create_timer(0.3).timeout;


func check_for_seal(entity : EntityController, player_side : bool, override_flags : Array[TFlag]) -> bool:
	var action = entity.current_action;
	
	# Realistically should never be null but w/e, safety check
	if action == null || (action != null && action.ignore_seals) : return false;
	var has_sealed = false;
	var has_learned = false;
	
	for seal in seal_instances:
		if seal.player_side == player_side : continue;
		
		# Check if entity's seals are active
		if !seal.seal_entity.seals_active : continue;
		
		var flags = action.spell_flags.duplicate();
		
		if override_flags != null :
			flags = override_flags;
		
		# Add the kind in so we don't need to duplicate code.
		# We cannot move the code in loop.
		flags.append(action.spell_kind);
		
		for flag in flags:
			# NOTE: This will double effects up and do a violation per flag. 
			# If we don't want this, pull it out of the loop.
			var sealed = false;
			
			if seal.seal_source.spell_flags.has(flag) || seal.seal_source.spell_kind == flag :
				
				var kind_overlap = seal.seal_source.spell_kind == flag;
				
				if !sealed || kind_overlap : 
					has_sealed = true;
					sealed = true;
					
					_play_seal_message(seal, entity);
					
					# Get primary flag
					var effects = _get_primary_seal_effect(seal.seal_source.spell_flags);
					
					if effects == null : continue;
					
					for eff in effects.seal_effects: #seal.seal_effect.seal_effects:
						var eff_instance = eff.create_effect_instance(seal.seal_entity, entity, null);
						# May be vestigal with how seals work now
						eff_instance.spell_override = seal.seal_source;
						eff_instance.check_success();
						if eff_instance.cast_success : eff_instance.on_activate();
						if !eff_instance.applied : eff_instance.free();
						
						if kind_overlap :
							eff_instance.turn_limit = roundi((eff.turn_limit) / 2.0)
					
					_play_seal_effects(seal, seal.seal_entity, flag, false);
					
					# Learn spell if seal is on player's side
					if seal.player_side && action.is_learnable :
						EventManager.learn_move_from_seal.emit(seal.seal_entity, action);
						has_learned = true;
	
	return has_sealed;


func _get_primary_seal_effect(flags : Array[TFlag]) -> SealEffectGroup:
	if flags.size() > 0 :
		var primary = flags[0];
		
		for flag in seal_vfx:
			if flag.flag == primary :
				return flag.effect;
	
	return null;


func _play_seal_message(seal : SealInstance, entity : EntityController) :
	var seal_msg = tr("T_BATTLE_ACTION_SEAL_ACTIVATE");
	
	if seal.seal_entity.current_entity.generic && BattleScene.Instance.enemy_type_count[seal.seal_entity.current_entity] <= 1:
		seal_msg = seal_msg.format({ article_def = GrammarManager.get_direct_article(seal.seal_entity.param.entity_name), entity = "[color=FFFF00]" + seal.seal_entity.param.entity_name + "[/color]" });
	else:
		seal_msg = seal_msg.format({ article_def = "", entity = "[color=FFFF00]" + seal.seal_entity.param.entity_name + "[/color]" });
	
	if entity.current_entity.generic && BattleScene.Instance.enemy_type_count[entity.current_entity] <= 1:
		seal_msg = seal_msg.format({ t_article_def = GrammarManager.get_direct_article(entity.param.entity_name), t_entity = "[color=FFFF00]" + entity.param.entity_name + "[/color]" });
	else: 
		seal_msg = seal_msg.format({ t_article_def = "", t_entity = "[color=FFFF00]" + entity.param.entity_name + "[/color]" });
	
	var action_name = "";
	if seal.seal_source.spell_name_key.is_empty() || (BattleManager.ENEMY_SEAL_FORCE_GENERIC_NAME && seal.seal_entity is EnemyController):
		action_name = tr("T_SPELL_GENERIC_PRONOUN");
		action_name = action_name.format({ pronoun3 = GrammarManager.get_pronoun(seal.seal_entity.param.entity_gender, 3) })
	else :
		action_name = tr(seal.seal_source.spell_name_key);
	
	seal_msg = seal_msg.format({ action = action_name, t_action = "" });
	EventManager.on_dialogue_queue.emit(seal_msg);


func get_seal_overlap_count(spell : Spell, player_side : bool) -> int:
	var seal_count = 0;
	
	for seal in seal_instances:
		if seal.player_side != player_side : continue;
		
		for flag in spell.spell_flags:
			if seal.seal_source.spell_flags.has(flag):
				seal_count += 1;
		
		if seal.seal_source.spell_kind == spell.spell_kind :
			seal_count += 1;
	
	return seal_count;


func get_player_seal_count() -> int:
	var seal_count = 0;
	
	for seal in seal_instances:
		if seal.player_side == false : continue;
		else : seal_count += 1;
	
	return seal_count;


func _play_seal_effects(seal : SealInstance, target : EntityController, show_only : TFlag = null, creating : bool = true, activate : bool = true) :
	var vfx : Array[Node];
	
	for flag in seal_vfx:
		if (seal.seal_source.spell_flags.has(flag.flag) || seal.seal_source.spell_kind == flag.flag) && (show_only == null || (show_only != null && flag.flag == show_only)):
			vfx.append(_play_seal_effect(flag, target, activate));
			
			if !activate :
				print("Expire SFX");
				AudioManager.play_sfx("seal_proc");
			else :
				if creating : AudioManager.play_sfx("seal_active");
				else : AudioManager.play_sfx("seal_proc");
			
			await get_tree().create_timer(0.3).timeout;
	
	await get_tree().create_timer(1).timeout;
	
	for vfx_instance in vfx:
		vfx_instance.queue_free();


func _play_seal_effect(flag : SealData, target : EntityController, activate : bool = true) -> Node :
	var vfx_scene : PackedScene;
	
	if (activate) : vfx_scene = flag.vfx;
	else : vfx_scene = flag.expire_vfx;
	
	# Dunno how or why a failsafe was missing
	if (vfx_scene == null) : return;
	
	var vfx_instance = vfx_scene.instantiate() as EntityBase;
	target.get_tree().root.add_child(vfx_instance);
	
	vfx_instance.global_position = target.global_position + target.get_sprite_mid_offset();
	vfx_instance.reset_physics_interpolation();
	
	return vfx_instance;


func _on_entity_turn_end(entity : EntityController) :
	# Do not increment enemy seals if the experimental change is active
	if entity is EnemyController && BattleManager.ENEMY_SEAL_INFINITE:
		return;
	
	var i : int = 0;
	while i < seal_instances.size():
		if seal_instances[i].seal_entity == entity:
			seal_instances[i].seal_turn_count -= 1;
			
			if seal_instances[i].seal_turn_count < 0:
				_send_seal_inactive_message(seal_instances[i], entity);
				
				for flag in seal_instances[i].seal_source.spell_flags :
					_play_seal_effects(seal_instances[i], entity, flag, false, false);
					await get_tree().create_timer(0.3).timeout;
				
				_play_seal_effects(seal_instances[i], entity, seal_instances[i].seal_source.spell_kind, false, false);
				await get_tree().create_timer(0.3).timeout;
				
				seal_instances[i].free();
				seal_instances.remove_at(i);
				i -= 1;
		
		i += 1;


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_begin.disconnect(_on_battle_begin);
		EventManager.on_entity_defeated.disconnect(_on_entity_defeated);
		EventManager.on_entity_turn_end.disconnect(_on_entity_turn_end);
	
	if BattleManager != null && BattleManager.seal_manager == self:
		BattleManager.seal_manager = null;
