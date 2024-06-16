extends Button
class_name MagicButtonUI

var action : Spell;
@onready var mp_label : Label = $"MP Label";


func init_button(_action : Spell):
	action = _action;
	text = action.spell_name_key;
	mp_label.text = str(_action.spell_cost) + tr("T_MP");
	theme_type_variation = "Button";


func set_sealing(sealing : bool):
	if action :
		if sealing :
			mp_label.text = str(action.spell_cost * Spell.SEAL_COST_MULTIPLIER) + tr("T_MP");
			theme_type_variation = "SealButton";
		else:
			mp_label.text = str(action.spell_cost) + tr("T_MP");
			theme_type_variation = "Button";


func _on_pressed():
	EventManager.on_action_selected.emit(action);
