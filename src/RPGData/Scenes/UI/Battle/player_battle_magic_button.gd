extends Button
class_name MagicButtonUI

var action : Spell;
var entity : EntityController;
var sealing : bool;
@onready var mp_label : Label = $"MP Label";


func init_button(_action : Spell, _entity : EntityController):
	action = _action;
	entity = _entity;
	text = action.spell_name_key;
	mp_label.text = str(_action.spell_cost) + tr("T_MP");
	theme_type_variation = "Button";
	sealing = false;
	set_sealing(false);


func set_sealing(_sealing : bool):
	if action :
		sealing = _sealing;
		
		if sealing :
			disabled = entity.current_mp < ceili(action.spell_cost * Spell.SEAL_COST_MULTIPLIER);
			if !disabled : disabled = !BattleScene.Instance.can_seal(action);
			
			mp_label.text = str(ceili(action.spell_cost * Spell.SEAL_COST_MULTIPLIER)) + tr("T_MP");
			theme_type_variation = "SealButton";
		else:
			disabled = entity.current_mp < action.spell_cost;
			mp_label.text = str(action.spell_cost) + tr("T_MP");
			theme_type_variation = "Button";
		
		if action.target_defeated_entities : 
			disabled = BattleScene.Instance.get_num_active_players(true) == 0;
		if action.ignore_self :
			disabled = BattleScene.Instance.get_num_active_players(false) <= 1;


func _on_pressed():
	EventManager.on_action_selected.emit(action, sealing);
