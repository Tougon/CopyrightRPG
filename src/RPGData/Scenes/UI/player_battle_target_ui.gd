extends MenuPanel

@export var info_scene: PackedScene = preload("res://src/RPGData/Scenes/UI/player_battle_target_entry_ui.tscn");
@export var arrow_scene: PackedScene = preload("res://src/RPGData/Scenes/UI/player_battle_target_arrow_ui.tscn");
@export var pool_size : int = 10;
@export var entity_info : EntityInfoUI;

var target_info_pool : Array[UIBattleTargetInfo]
var target_arrow_pool : Array[Control];
var target_to_info: Dictionary;

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.initialize_target_menu.connect(_initialize_target_menu);
	EventManager.highlight_target.connect(_on_target_highlighted);
	
	for i in pool_size:
		var info = info_scene.instantiate() as UIBattleTargetInfo;
		$".".add_child(info);
		info.visible = false;
		info.name = "Info " + str(i + 1);
		target_info_pool.append(info);
		all_selections.append(info);
		
		if initial_selection == null:
			initial_selection = info;
		
		var arrow = arrow_scene.instantiate() as Control;
		$".".add_child(arrow);
		arrow.visible = false;
		arrow.name = "Arrow " + str(i + 1);
		target_arrow_pool.append(arrow);
	
	super._ready();


func set_focus(state : bool):
	super.set_focus(state);
	
	if state:
		EventManager.click_target.connect(_on_target_clicked);
	else:
		EventManager.click_target.disconnect(_on_target_clicked);



func _initialize_target_menu(entity : EntityController):
	if entity.current_action == null:
		return;
	
	target_to_info.clear();
	var spell_target = entity.current_action.spell_target;
	var targets = entity.get_possible_targets();
	# TODO: implement behavior for random targetting.
	# This was not in the old project
	
	if spell_target == Spell.SpellTarget.All || spell_target == Spell.SpellTarget.AllEnemy || spell_target == Spell.SpellTarget.AllParty:
		var info = target_info_pool[0];
		info.visible = true;
		
		var arrows : Array[Control];
		
		for i in targets.size():
			var arrow = target_arrow_pool[i];
			arrow.visible = true;
			arrow.position = targets[i].position;
			arrows.append(arrow);
		
		info.initialize(targets, arrows, entity, true);
		
		for i in range(1, pool_size):
			if i > targets.size():
				target_arrow_pool[i].visible = false;
			target_info_pool[i].visible = false;
		
	else:
		for i in targets.size():
			var target = targets[i];
			var info = target_info_pool[i];
			
			info.visible = true;
			info.global_position = target.global_position;
			
			info.initialize([target], [target_arrow_pool[i]], entity, false);
			target_to_info[target] = info;
		
		for i in range(targets.size(), pool_size):
			target_info_pool[i].visible = false;
			target_arrow_pool[i].visible = false;


func _on_target_highlighted(entity : EntityController, all : bool):
	entity_info.set_specific_entity_info(entity, all);


func _on_target_clicked(entity : EntityController):
	var info = target_to_info.get(entity);
	if info:
		if info.selected:
			info.select_target();
		else:
			info.grab_focus();


func on_menu_cancel():
	UIManager.open_menu_name("player_battle_main");
	super.on_menu_cancel();


func _on_destroy():
	if EventManager != null:
		EventManager.initialize_target_menu.disconnect(_initialize_target_menu);
		EventManager.highlight_target.disconnect(_on_target_highlighted);
