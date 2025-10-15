extends Button
class_name MagicButtonUI

var action : Spell;
var entity : EntityController;
var sealing : bool;
@onready var text_label : Label = $"Label";
@onready var mp_label : Label = $"MP Label";
@onready var flag_group : FlagIconGroup = $"Flag Icon Group";

var _cost : int;


func init_button(_action : Spell, _entity : EntityController):
	action = _action;
	entity = _entity;
	_cost = _action.spell_cost;
	
	text_label.text = action.spell_name_key;
	mp_label.text = str(_action.spell_cost) + tr("T_MP");
	flag_group.display_flags(action.spell_flags);
	
	theme_type_variation = "Button";
	sealing = false;
	set_sealing(false);


func set_sealing(_sealing : bool):
	if action :
		sealing = _sealing;
		
		if sealing :
			disabled = entity.current_mp < ceili(action.spell_cost * Spell.SEAL_COST_MULTIPLIER);
			if !disabled : disabled = !BattleScene.Instance.can_seal(action);
			
			_cost = ceili(action.spell_cost * Spell.SEAL_COST_MULTIPLIER);
			mp_label.text = str(_cost) + tr("T_MP");
			theme_type_variation = "SealButton";
		else:
			disabled = entity.current_mp < action.spell_cost;
			_cost = action.spell_cost;
			mp_label.text = str(_cost) + tr("T_MP");
			theme_type_variation = "Button";
		
		if action.target_defeated_entities : 
			disabled = BattleScene.Instance.get_num_active_players(true) == 0;
		if action.ignore_self :
			disabled = BattleScene.Instance.get_num_active_players(false) <= 1;
		
		if UIManager.current_selection == self :
			flag_group.set_sealing(sealing && !disabled);
			EventManager.on_action_highlighted.emit(action, _cost, !disabled);
		else :
			flag_group.set_sealing(false);


func _on_pressed():
	EventManager.on_action_selected.emit(action, sealing);


func _on_focus_entered() :
	EventManager.on_action_highlighted.emit(action, _cost, !disabled);
	flag_group.set_sealing(sealing && !disabled);


func _on_focus_exited() -> void:
	flag_group.set_sealing(false);
