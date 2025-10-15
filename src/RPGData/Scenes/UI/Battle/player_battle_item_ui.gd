extends MenuPanel

@export var menu_panel : DynamicMenuPanel;

var current_entity : EntityController;

var _item_buttons : Array[ItemButtonUI];
var _selection_index : int;

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready();
	
	if menu_panel.is_ready : 
		_init_menu_panel_items(menu_panel.get_menu_item_groups());
	else:
		menu_panel.on_menu_items_ready.connect(_init_menu_panel_items);


func _init_menu_panel_items(item_groups : Array[Array]) :
	print("Yeah")
	for group in item_groups :
		for item in group :
			var item_button = (item as ItemButtonUI)
			
			if item_button != null :
				_item_buttons.append(item_button);


func _enter_tree():
	super._enter_tree();
	
	EventManager.set_active_player.connect(_set_active_entity);
	EventManager.initialize_item_menu.connect(_initialize_item_menu);


func _set_active_entity(entity : EntityController, is_first : bool):
	current_entity = entity;
	current_entity.current_item = null;
	
	for item_button in _item_buttons :
		item_button.entity = current_entity;


func _initialize_item_menu(entity : EntityController):
	var item_list = entity.item_list;
	var usable_item_list : Array[ConsumableItem]
	var _selection_index = 0;
	
	for i in item_list.keys().size():
		var item = item_list.keys()[i] as ConsumableItem;
		
		# NOTE: This originally blocked if item quantity was 0.
		# I personally think a better way to handle this is grey out 0 count items
		# The only time the player sees them is on their turn before it's used
		if item == null : continue;
		
		usable_item_list.append(item);
		
		# If this is the last used attack, set selection
		if (current_entity.current_action != null && item.battle_effect == current_entity.current_action) || item.battle_effect == current_entity.prev_action :
			_selection_index = usable_item_list.size();
	
	menu_panel.set_data(usable_item_list);


func on_focus():
	super.on_focus();
	menu_panel.set_selected_index(_selection_index);


func on_menu_cancel():
	current_entity.current_item = null;
	
	UIManager.open_menu_name("player_battle_main");
	super.on_menu_cancel();


func _on_panel_removed():
	super._on_panel_removed();
	if EventManager != null:
		EventManager.set_active_player.disconnect(_set_active_entity);
		EventManager.initialize_item_menu.disconnect(_initialize_item_menu);
