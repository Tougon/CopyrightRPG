extends MenuPanel

var current_entity : EntityController;

@export var button_count : int = 30;
@export var buttons_per_row : int = 3;
@export var move_button : PackedScene;
@export var button_spacer : PackedScene;
@export var button_root : Node;


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in button_count :
		var button = move_button.instantiate() as ItemButtonUI;
		var spacer = button_spacer.instantiate() as Control;
		
		button_root.add_child(spacer);
		button_root.add_child(button);
		
		all_selections.append(button);
	
	super._ready();


func _enter_tree():
	super._enter_tree();
	
	EventManager.set_active_player.connect(_set_active_entity);
	EventManager.initialize_item_menu.connect(_initialize_item_menu);


func _set_active_entity(entity : EntityController):
	current_entity = entity;
	current_entity.current_item = null;


func _initialize_item_menu(entity : EntityController):
	var item_list = entity.item_list;
	var default_selection = true;
	var last_row_index = _get_bottom_row_start_index(item_list.size());
	
	for i in item_list.keys().size():
		var item = item_list.keys()[i] as ConsumableItem;
		
		# NOTE: This originally blocked if item quantity was 0.
		# I personally think a better way to handle this is grey out 0 count items
		# The only time the player sees them is on their turn before it's used
		if item == null : continue;
		
		# If this is the last used attack, set selection
		if (current_entity.current_action != null && item.battle_effect == current_entity.current_action) || item.battle_effect == current_entity.prev_action :
			initial_selection = all_selections[i];
			default_selection = false;
		
		(all_selections[i] as ItemButtonUI).init_button(item, item.battle_effect, entity);
		all_selections[i].visible = true;
		
		all_selections[i].focus_neighbor_top = "";
		all_selections[i].focus_neighbor_left = "";
		all_selections[i].focus_neighbor_right = "";
		all_selections[i].focus_neighbor_bottom = "";
		
		# If we're in the first row, wrap to the bottom
		if i < buttons_per_row && item_list.keys().size() > buttons_per_row:
			var index = last_row_index + (i % buttons_per_row);
			while index >= item_list.keys().size() : index -= 1;
			all_selections[i].focus_neighbor_top = all_selections[index].get_path();
		
		# If we're in the bottom row, wrap to the top
		if i >= last_row_index:
			var index = i % buttons_per_row;
			all_selections[i].focus_neighbor_bottom = all_selections[index].get_path();
			
			if i == item_list.keys().size() - 1 : 
				all_selections[i].focus_neighbor_right = all_selections[last_row_index].get_path();
		
		# At the start and end of a row, wrap around.
		if i % buttons_per_row == 0:
			var index = i + buttons_per_row - 1;
			while index >= item_list.keys().size(): index -= 1;
			all_selections[i].focus_neighbor_left = all_selections[index].get_path();
		elif i % buttons_per_row == buttons_per_row - 1 :
			var index = i;
			while index % buttons_per_row != 0: index -= 1;
			all_selections[i].focus_neighbor_right = all_selections[index].get_path();
		elif i == item_list.keys().size() - 1 && item_list.keys().size() <= buttons_per_row:
			all_selections[i].focus_neighbor_right = all_selections[0].get_path();
	
	if default_selection && item_list.keys().size() > 0:
		initial_selection = all_selections[0];
	
	for i in range(item_list.keys().size(), all_selections.size()):
		all_selections[i].visible = false;


func _get_bottom_row_start_index(size : int) -> int:
	if size < buttons_per_row : return size - 1;
	elif size % buttons_per_row == 0 : return size - buttons_per_row;
	return size - (size % buttons_per_row);


func on_menu_cancel():
	current_entity.current_item = null;
	
	UIManager.open_menu_name("player_battle_main");
	super.on_menu_cancel();


func _on_panel_removed():
	super._on_panel_removed();
	if EventManager != null:
		EventManager.set_active_player.disconnect(_set_active_entity);
		EventManager.initialize_item_menu.disconnect(_initialize_item_menu);
