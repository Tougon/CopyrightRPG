extends Node
class_name SealManager

const SEAL_TURN_COUNT : int = 4;
const MAX_SEALS_PER_SIDE : int = 4;

var seal_instances : Array[SealInstance];
var sealed_spells : Array[Spell];

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.on_battle_begin.connect(_on_battle_begin);
	EventManager.on_entity_defeated.connect(_on_entity_defeated);
	EventManager.on_entity_move.connect(_on_entity_move);
	
	if BattleManager.seal_manager == null:
		BattleManager.seal_manager = self;


func _on_battle_begin():
	seal_instances = [];
	sealed_spells = [];


func _on_entity_defeated(entity : EntityController):
	for i in seal_instances.size():
		var seal = seal_instances[i];
		
		if seal.seal_entity == entity:
			# Should we send a message saying the seal has been lifted?
			# Perhaps only if player?
			seal_instances.remove_at(i);
			i -= 1;


func can_seal_spell(spell : Spell) -> bool:
	return !sealed_spells.has(spell);


func create_seal_instance(entity : EntityController, spell : Spell, effect : SealEffectGroup, player_side : bool):
	if effect == null : return;
	
	var seal_inst = SealInstance.new(entity, spell, effect, SEAL_TURN_COUNT, player_side);
	seal_instances.append(seal_inst);


func check_for_seal(entity : EntityController, player_side : bool) -> bool:
	var action = entity.current_action;
	
	# Realistically should never be null but w/e, safety check
	if action == null : return false;
	var sealed = false;
	
	for seal in seal_instances:
		if seal.player_side == player_side : continue;
		
		# NOTE: This will double effects up and do a violation per flag.
		# Maybe we don't want this?
		for flag in action.spell_flags:
			if seal.seal_source.spell_flags.has(flag):
				
				if !sealed : 
					sealed = true;
					var seal_msg = tr("T_BATTLE_ACTION_SEAL_ACTIVATE");
					
					if seal.seal_entity.current_entity.generic :
						seal_msg = seal_msg.format({ article_def = GrammarManager.get_direct_article(seal.seal_entity.param.entity_name), entity = seal.seal_entity.param.entity_name });
					else:
						seal_msg = seal_msg.format({ article_def = "", entity = seal.seal_entity.param.entity_name });
					
					if entity.current_entity.generic :
						seal_msg = seal_msg.format({ t_article_def = GrammarManager.get_direct_article(entity.param.entity_name), t_entity = entity.param.entity_name });
					else: 
						seal_msg = seal_msg.format({ t_article_def = "", t_entity = entity.param.entity_name });
					
					seal_msg = seal_msg.format({ action = tr(seal.seal_source.spell_name_key) });
					EventManager.on_dialogue_queue.emit(seal_msg);
				
				
				for eff in seal.seal_effect.seal_effects:
					var eff_instance = eff.create_effect_instance(seal.seal_entity, entity, null);
					# May be vestigal with how seals work now
					eff_instance.spell_override = seal.seal_source;
					eff_instance.check_success();
					if eff_instance.cast_success : eff_instance.on_activate();
	
	return sealed;


func _on_entity_move(entity : EntityController) :
	for i in seal_instances.size():
		if seal_instances[i].seal_entity == entity:
			seal_instances[i].seal_turn_count -= 1;
			
			if seal_instances[i].seal_turn_count <= 0:
				seal_instances.remove_at(i);
				i -= 1;
				# TODO: send message that seal has expired Somehow


func _on_destroy():
	if EventManager != null:
		EventManager.on_battle_begin.disconnect(_on_battle_begin);
		EventManager.on_entity_defeated.disconnect(_on_entity_defeated);
		EventManager.on_entity_move.disconnect(_on_entity_move);
	
	if BattleManager != null && BattleManager.seal_manager == self:
		BattleManager.seal_manager = null;
