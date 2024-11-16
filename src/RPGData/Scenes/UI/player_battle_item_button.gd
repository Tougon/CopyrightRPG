extends Button
class_name ItemButtonUI

var action : Spell;
var entity : EntityController;
var sealing : bool;


func init_button(_item : Item, _action : Spell, _entity : EntityController):
	action = _action;
	entity = _entity;
	text = action.spell_name_key;
	theme_type_variation = "Button";
	sealing = false;
	set_sealing(false);


func set_sealing(_sealing : bool):
	if action :
		sealing = _sealing;
		
		if sealing :
			disabled = entity.current_mp < ceili(action.spell_cost * Spell.SEAL_COST_MULTIPLIER);
			if !disabled : disabled = !BattleScene.Instance.can_seal(action);
			
			theme_type_variation = "SealButton";
		else:
			disabled = entity.current_mp < action.spell_cost;
			theme_type_variation = "Button";


func _on_pressed():
	EventManager.on_action_selected.emit(action, sealing);
