extends Button
class_name ItemButtonUI

var item : Item;
var action : Spell;
var entity : EntityController;
@onready var quantity_label : Label = $"Quantity Label";


func init_button(_item : Item, _action : Spell, _entity : EntityController):
	item = _item;
	action = _action;
	entity = _entity;
	text = action.spell_name_key;
	if _entity.item_list.has(_item) : 
		var amt = _entity.item_list[_item];
		quantity_label.text = "x" + str(amt);
		disabled = amt <= 0;
	
	theme_type_variation = "Button";


func _on_pressed():
	if entity == null : return;
	entity.current_item = item;
	EventManager.on_action_selected.emit(action, false);
