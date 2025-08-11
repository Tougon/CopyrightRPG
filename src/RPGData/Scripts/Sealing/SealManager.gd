extends Node
class_name SealManager

@export var seal_vfx : Array[SealVFX];

const SEAL_TURN_COUNT : int = 4;
const MAX_SEALS_PER_SIDE : int = 4;

var seal_instances : Array[SealInstance];
var sealed_spells : Array[Spell];

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
	
	while index < seal_instances.size() && seal_instances.size() > 0:
		var seal = seal_instances[index];
		
		if seal.seal_entity == entity:
			# Send a message saying the seal has been lifted
			# TODO: Do not do if the battle is over
			_send_seal_inactive_message(seal, entity);
			
			seal_instances[index].free();
			seal_instances.remove_at(index);
		else :
			index += 1;


func _send_seal_inactive_message(seal : SealInstance, entity : EntityController):
	var seal_msg = tr("T_BATTLE_ACTION_SEAL_INACTIVE");
	var seal_entity_name = "[color=FFFF00]" + seal.seal_entity.param.entity_name + "[/color]"
	var entity_name = "[color=FFFF00]" + entity.param.entity_name + "[/color]"
	
	if seal.seal_entity.current_entity.generic && BattleScene.Instance.enemy_type_count[seal.seal_entity.current_entity] && BattleScene.Instance.enemy_type_count[seal.seal_entity.current_entity] <= 1:
		seal_msg = seal_msg.format({ article_def = GrammarManager.get_direct_article(seal.seal_entity.param.entity_name), entity = seal_entity_name });
	else:
		seal_msg = seal_msg.format({ article_def = "", entity = seal_entity_name });
	
	if entity.current_entity.generic && BattleScene.Instance.enemy_type_count[entity.current_entity] && BattleScene.Instance.enemy_type_count[entity.current_entity] <= 1:
		seal_msg = seal_msg.format({ t_article_def = GrammarManager.get_direct_article(entity.param.entity_name), t_entity = entity_name });
	else: 
		seal_msg = seal_msg.format({ t_article_def = "", t_entity = entity_name });
	
	seal_msg = seal_msg.format({ action = tr(seal.seal_source.spell_name_key) });
	EventManager.on_dialogue_queue.emit(seal_msg);


func can_seal_spell(spell : Spell) -> bool:
	return !sealed_spells.has(spell);


func create_seal_instance(entity : EntityController, spell : Spell, effect : SealEffectGroup, player_side : bool):
	if effect == null : return;
	
	var turn_count : int = SEAL_TURN_COUNT;
	
	# We need to add an extra turn because otherwise the turn it's active counts
	# This effectively means 3 turns is 2.
	if BattleManager.seal_before_attacking : turn_count += 1;
	if effect.override_turn_count : turn_count = effect.override_turn_count;
	
	var seal_inst = SealInstance.new(entity, spell, effect, turn_count, player_side);
	seal_instances.append(seal_inst);
	
	# Add spell to the sealed list
	sealed_spells.append(spell);
	
	EventManager.set_player_bg.emit(entity);
	_play_seal_effects(seal_inst, entity);


func check_for_seal(entity : EntityController, player_side : bool, override_flags : Array[TFlag]) -> bool:
	var action = entity.current_action;
	
	# Realistically should never be null but w/e, safety check
	if action == null || (action != null && action.ignore_seals) : return false;
	var has_sealed = false;
	
	for seal in seal_instances:
		if seal.player_side == player_side : continue;
		
		# Check if entity's seals are active
		if seal.seal_entity.seals_active : continue;
		
		# NOTE: This will double effects up and do a violation per flag.
		var flags = action.spell_flags.duplicate();
		
		if override_flags != null :
			flags = override_flags;
		
		for flag in flags:
			var sealed = false;
			
			if seal.seal_source.spell_flags.has(flag):
				
				if !sealed : 
					has_sealed = true;
					sealed = true;
					var seal_msg = tr("T_BATTLE_ACTION_SEAL_ACTIVATE");
					
					if seal.seal_entity.current_entity.generic && BattleScene.Instance.enemy_type_count[seal.seal_entity.current_entity] <= 1:
						seal_msg = seal_msg.format({ article_def = GrammarManager.get_direct_article(seal.seal_entity.param.entity_name), entity = "[color=FFFF00]" + seal.seal_entity.param.entity_name + "[/color]" });
					else:
						seal_msg = seal_msg.format({ article_def = "", entity = "[color=FFFF00]" + seal.seal_entity.param.entity_name + "[/color]" });
					
					if entity.current_entity.generic && BattleScene.Instance.enemy_type_count[entity.current_entity.generic] <= 1:
						seal_msg = seal_msg.format({ t_article_def = GrammarManager.get_direct_article(entity.param.entity_name), t_entity = "[color=FFFF00]" + entity.param.entity_name + "[/color]" });
					else: 
						seal_msg = seal_msg.format({ t_article_def = "", t_entity = "[color=FFFF00]" + entity.param.entity_name + "[/color]" });
					
					seal_msg = seal_msg.format({ action = tr(seal.seal_source.spell_name_key) });
					EventManager.on_dialogue_queue.emit(seal_msg);
				
					for eff in seal.seal_effect.seal_effects:
						var eff_instance = eff.create_effect_instance(seal.seal_entity, entity, null);
						# May be vestigal with how seals work now
						eff_instance.spell_override = seal.seal_source;
						eff_instance.check_success();
						if eff_instance.cast_success : eff_instance.on_activate();
						if !eff_instance.applied : eff_instance.free();
					
					_play_seal_effects(seal, entity, flag);
	
	return has_sealed;


func get_seal_overlap_count(spell : Spell, player_side : bool) -> int:
	var seal_count = 0;
	
	for seal in seal_instances:
		if seal.player_side != player_side : continue;
		
		for flag in spell.spell_flags:
			if seal.seal_source.spell_flags.has(flag):
				seal_count += 1;
	
	return seal_count;


func _play_seal_effects(seal : SealInstance, target : EntityController, show_only : TFlag = null) :
	var vfx : Array[Node];
	
	for flag in seal_vfx:
		if seal.seal_source.spell_flags.has(flag.flag) && (show_only == null || (show_only != null && flag.flag == show_only)):
			vfx.append(_play_seal_effect(flag, target));
			await get_tree().create_timer(0.3).timeout;
	
	await get_tree().create_timer(1).timeout;
	
	for vfx_instance in vfx:
		vfx_instance.queue_free();


func _play_seal_effect(flag : SealVFX, target : EntityController) -> Node :
	var vfx_instance = flag.vfx.instantiate() as EntityBase;
	target.get_tree().root.add_child(vfx_instance);
	
	vfx_instance.global_position = target.global_position;
	vfx_instance.reset_physics_interpolation();
	
	return vfx_instance;


func _on_entity_turn_end(entity : EntityController) :
	var i : int = 0;
	while i < seal_instances.size():
		if seal_instances[i].seal_entity == entity:
			seal_instances[i].seal_turn_count -= 1;
			
			if seal_instances[i].seal_turn_count <= 0:
				_send_seal_inactive_message(seal_instances[i], entity);
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
