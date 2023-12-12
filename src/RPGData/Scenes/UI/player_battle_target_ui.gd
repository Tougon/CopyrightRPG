extends MenuPanel

@export var info_scene: PackedScene = preload("res://src/RPGData/Scenes/UI/player_battle_target_entry_ui.tscn");
@export var arrow_scene: PackedScene = preload("res://src/RPGData/Scenes/UI/player_battle_target_arrow_ui.tscn");
@export var pool_size : int = 10;

var target_info_pool : Array[UIBattleTargetInfo]
var target_arrow_pool : Array[Control];

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.initialize_target_menu.connect(_initialize_target_menu);
	
	for i in pool_size:
		var info = info_scene.instantiate() as UIBattleTargetInfo;
		$".".add_child(info);
		info.visible = false;
		target_info_pool.append(info);
		
		var arrow = arrow_scene.instantiate() as Control;
		$".".add_child(arrow);
		arrow.visible = false;
		target_arrow_pool.append(arrow);
	
	super._ready();


func _initialize_target_menu(entity : EntityController):
	if entity.current_action == null:
		return;
	
	var spell_target = entity.current_action.spell_target;
	var targets = entity.get_possible_targets();
	# TODO: implement behavior for random targetting.
	# This was not in the old project
	
	# TODO: All
	if spell_target == Spell.SpellTarget.All || spell_target == Spell.SpellTarget.AllEnemy || spell_target == Spell.SpellTarget.AllParty:
		pass;
	else:
		for i in targets.size():
			var target = targets[i];
			var info = target_info_pool[i];
			
			info.visible = true;
			info.global_position = target.global_position;
			
			info.initialize([target], [target_arrow_pool[i]], entity);
		
		for i in range(targets.size(), pool_size):
			target_info_pool[i].visible = false;
			target_arrow_pool[i].visible = false;


func _on_destroy():
	if EventManager != null:
		EventManager.initialize_target_menu.disconnect(_initialize_target_menu);
