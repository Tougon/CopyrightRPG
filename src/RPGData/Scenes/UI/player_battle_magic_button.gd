extends Button
class_name MagicButtonUI

var action : Spell;
@onready var mp_label : Label = $"MP Label";

func init_button(_action : Spell):
	action = _action;
	text = action.spell_name_key;
	mp_label.text = str(_action.spell_cost) + tr("T_MP");


func _on_pressed():
	EventManager.on_action_selected.emit(action);
