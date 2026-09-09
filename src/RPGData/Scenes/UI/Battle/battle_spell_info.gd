extends Panel

const MAX_DISPLAY_TIME : float = 2.0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.battle_action_show.connect(_on_battle_action_show)
	self.visible = false;


func _on_battle_action_show(action : Spell, visible : bool):
	self.visible = visible;
	
	if action != null :
		$"ColorRect/Container/Move Name".text = tr(action.spell_name_key).to_upper();
		$"ColorRect/Container/Flag Icon Group".display_flags(action.spell_flags);


func _on_destroy():
	if EventManager != null:
		EventManager.battle_action_show.disconnect(_on_battle_action_show)
