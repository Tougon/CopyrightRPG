extends Panel

const MAX_DISPLAY_TIME : float = 2.0;
@export var move_kind_icons : Array[Texture];


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.battle_action_show.connect(_on_battle_action_show)
	self.visible = false;


func _on_battle_action_show(action : Spell, sealing : bool, visible : bool):
	self.visible = visible;
	
	if visible && action != null :
		$"ColorRect/Container/Move Name".text = tr(action.spell_name_key).to_upper();
		
		$"ColorRect/Container/Flag Icon Group".display_flags(action.spell_flags);
		$"ColorRect/Container/Flag Icon Group".set_sealing(sealing);
		
		var kind = action.spell_kind;
		
		if kind != null :
			if kind.flag_name_key.contains("art") : $"ColorRect/Container/Kind Icon Root/Kind".texture = move_kind_icons[0];
			elif kind.flag_name_key.contains("science") : $"ColorRect/Container/Kind Icon Root/Kind".texture = move_kind_icons[1];
			elif kind.flag_name_key.contains("logic") : $"ColorRect/Container/Kind Icon Root/Kind".texture = move_kind_icons[2];
			elif kind.flag_name_key.contains("action") : $"ColorRect/Container/Kind Icon Root/Kind".texture = move_kind_icons[3];


func _on_destroy():
	if EventManager != null:
		EventManager.battle_action_show.disconnect(_on_battle_action_show)
