extends MenuPanel

var current_entity : EntityController;
var is_sealing : bool = false;

@export var button_count : int = 30;
@export var buttons_per_row : int = 3;
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
	var last_row_index = _get_bottom_row_start_index(move_list.size());
	
	is_sealing = false;
	
	for i in move_list.size():
		var move = move_list[i];
		
		# If this is the last used attack, set selection
		if move == current_entity.prev_action :
			initial_selection = all_selections[i];
			default_selection = false;
		
		(all_selections[i] as MagicButtonUI).init_button(move);
		all_selections[i].visible = true;
		all_selections[i].disabled = entity.current_mp < move.spell_cost;
		
		all_selections[i].focus_neighbor_top = "";
		all_selections[i].focus_neighbor_left = "";
		all_selections[i].focus_neighbor_right = "";
		all_selections[i].focus_neighbor_bottom = "";
		
		# If we're in the first row, wrap to the bottom
		if i < buttons_per_row && move_list.size() > buttons_per_row:
			var index = last_row_index + (i % buttons_per_row);
			while index >= move_list.size() : index -= 1;
			all_selections[i].focus_neighbor_top = all_selections[index].get_path();
		
		# If we're in the bottom row, wrap to the top
		if i >= last_row_index:
			var index = i % buttons_per_row;
			all_selections[i].focus_neighbor_bottom = all_selections[index].get_path();
			
			if i == move_list.size() - 1 : 
				all_selections[i].focus_neighbor_right = all_selections[last_row_index].get_path();
		
		# At the start and end of a row, wrap around.
		if i % buttons_per_row == 0:
			var index = i + buttons_per_row - 1;
			while index >= move_list.size(): index -= 1;
			all_selections[i].focus_neighbor_left = all_selections[index].get_path();
		elif i % buttons_per_row == buttons_per_row - 1 :
			var index = i;
			while index % buttons_per_row != 0: index -= 1;
			all_selections[i].focus_neighbor_right = all_selections[index].get_path();
		elif i == move_list.size() - 1 && move_list.size() <= buttons_per_row:
			all_selections[i].focus_neighbor_right = all_selections[0].get_path();
	
	if default_selection && move_list.size() > 0:
		initial_selection = all_selections[0];
	
	for i in range(move_list.size(), all_selections.size()):
		all_selections[i].visible = false;


func _get_bottom_row_start_index(size : int) -> int:
	if size < buttons_per_row : return size - 1;
	elif size % buttons_per_row == 0 : return size - buttons_per_row;
	return size - (size % buttons_per_row);


func on_menu_cancel():
	UIManager.open_menu_name("player_battle_main");
	super.on_menu_cancel();


func on_ui_aux_1():
	is_sealing = !is_sealing;
	
	for button in all_selections:
		(button as MagicButtonUI).set_sealing(is_sealing);
	
	super.on_ui_aux_1();


func _on_destroy():
	super._on_destroy();
	if EventManager != null:
		EventManager.set_active_player.disconnect(_set_active_entity);
		EventManager.initialize_magic_menu.disconnect(_initialize_magic_menu);
