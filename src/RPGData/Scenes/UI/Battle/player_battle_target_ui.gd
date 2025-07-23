extends MenuPanel

@export var info_scene: PackedScene = preload("res://src/RPGData/Scenes/UI/Battle/player_battle_target_entry_ui.tscn");
@export var arrow_scene: PackedScene = preload("res://src/RPGData/Scenes/UI/Battle/player_battle_target_arrow_ui.tscn");
@export var pool_size : int = 10;
@export var entity_info : EntityInfoUI;

var target_info_pool : Array[UIBattleTargetInfo]
var target_arrow_pool : Array[Control];
var target_to_info: Dictionary;
var listening_target = false;

# Called when the node enters the scene tree for the first time.
func _ready():
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


func _enter_tree():
	super._enter_tree();
	EventManager.initialize_target_menu.connect(_initialize_target_menu);
	EventManager.highlight_target.connect(_on_target_highlighted);


func set_focus(state : bool):
	super.set_focus(state);
	
	if state && !listening_target:
		listening_target = true;
		EventManager.click_target.connect(_on_target_clicked);
	elif !state && listening_target:
		EventManager.click_target.disconnect(_on_target_clicked);
		listening_target = false;



func _initialize_target_menu(entity : EntityController):
	if entity.current_action == null:
		return;
	
	target_to_info.clear();
	var spell_target = entity.current_action.spell_target;
	var targets = entity.get_possible_targets();
	# TODO: Perhaps only do this if the selected spell is the same?
	var selection_remind = false;
	
	if spell_target == Spell.SpellTarget.RandomEnemyPerHit :
		entity.current_target = targets;
		entity.is_ready = true;
		return;
	
	elif spell_target == Spell.SpellTarget.RandomEnemy :
		var random_index = randi_range(0, targets.size() - 1);
		entity.current_target = [ targets[random_index] ];
		entity.is_ready = true;
		return;
	
	elif spell_target == Spell.SpellTarget.All || spell_target == Spell.SpellTarget.AllEnemy || spell_target == Spell.SpellTarget.AllParty || spell_target == Spell.SpellTarget.AllExceptSelf:
		var info = target_info_pool[0];
		info.visible = true;
		
		var arrows : Array[Control];
		
		for i in targets.size():
			var arrow = target_arrow_pool[i];
			arrow.visible = true;
			arrows.append(arrow);
		
		info.initialize(targets, arrows, entity, true);
		
		for i in range(1, pool_size):
			if i > targets.size():
				target_arrow_pool[i].visible = false;
			target_info_pool[i].visible = false;
	
	elif spell_target == Spell.SpellTarget.AllEnemyExcept :
		var arrows : Array[Control];
		var temp_targets : Array[EntityController];
		
		for i in targets.size():
			var arrow = target_arrow_pool[i];
			arrow.visible = false;
			arrows.append(arrow);
			temp_targets.append(targets[i]);
		
		for i in targets.size():
			var arrow = arrows[i];
			arrows.erase(arrow);
			temp_targets.erase(targets[i]);
			
			var info = target_info_pool[i];
			info.visible = true;
			info.global_position = targets[i].global_position;
			
			info.initialize(temp_targets.duplicate(), arrows.duplicate(), entity, false);
			target_to_info[targets[i]] = info;
			
			temp_targets.insert(i, targets[i]);
			arrows.insert(i, arrow);
		return;
	
	else:
		for i in targets.size():
			var target = targets[i];
			var info = target_info_pool[i];
			
			info.visible = true;
			info.global_position = target.global_position;
			
			info.initialize([target], [target_arrow_pool[i]], entity, false);
			target_to_info[target] = info;
			
			# Set the initial selection if the last selection is valid
			if entity.prev_target.size() == 1 && entity.prev_target[0].current_entity== target.current_entity && entity.prev_target[0].param.entity_name == target.param.entity_name:
				initial_selection = info;
				selection_remind = true;
		
		for i in range(targets.size(), pool_size):
			target_info_pool[i].visible = false;
			target_arrow_pool[i].visible = false;
	
	if !selection_remind : 
		initial_selection = all_selections[0];


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
	#UIManager.open_menu_name("player_battle_main");
	super.on_menu_cancel();


func _on_panel_removed():
	if EventManager != null:
		EventManager.initialize_target_menu.disconnect(_initialize_target_menu);
		EventManager.highlight_target.disconnect(_on_target_highlighted);
