extends MenuPanel

var current_entity : EntityController;
@export var button_count : int = 30;
@export var move_button : PackedScene;
@export var button_spacer : PackedScene;
@export var button_root : Node;


# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.set_active_player.connect(_set_active_entity);
	EventManager.initialize_magic_menu.connect(_initialize_magic_menu);
	
	for i in button_count :
		var button = move_button.instantiate() as MagicButtonUI;
		var spacer = button_spacer.instantiate() as Control;
		
		button_root.add_child(spacer);
		button_root.add_child(button);
		
		all_selections.append(button);
	
	super._ready();


func _set_active_entity(entity : EntityController):
	current_entity = entity;

func _initialize_magic_menu(entity : EntityController):
	var move_list = entity.move_list;
	var default_selection = true;
	
	for i in move_list.size():
		var move = move_list[i];
		
		# If this is the last used attack, set selection
		if move == current_entity.prev_action :
			initial_selection = all_selections[i];
			default_selection = false;
		
		(all_selections[i] as MagicButtonUI).init_button(move);
		all_selections[i].visible = true;
		all_selections[i].disabled = entity.current_mp < move.spell_cost;
	
	if default_selection && move_list.size() > 0:
		initial_selection = all_selections[0];
	
	for i in range(move_list.size(), all_selections.size()):
		all_selections[i].visible = false;


func on_menu_cancel():
	UIManager.open_menu_name("player_battle_main");
	super.on_menu_cancel();


func _on_destroy():
	super._on_destroy();
	if EventManager != null:
		EventManager.set_active_player.disconnect(_set_active_entity);
		EventManager.initialize_magic_menu.disconnect(_initialize_magic_menu);
