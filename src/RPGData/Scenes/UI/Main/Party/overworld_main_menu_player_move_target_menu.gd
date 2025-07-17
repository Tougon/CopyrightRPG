extends MenuPanel

@export var preview_image : TextureRect;
@export var hp_bar_current : UnderlayBar;
@export var mp_bar_current : UnderlayBar;

var _current_spell : Spell;
var _current_user : int = -1;
var _current_index : int = -1;
var _awaiting_input : bool = false;

func _ready():
	super._ready();
	
	EventManager.on_player_spell_attempt_use.connect(_on_player_spell_attempt_use);
	
	for i in all_selections.size():
		(all_selections[i] as Button).focus_entered.connect(_on_player_selected.bind(i))
		(all_selections[i] as Button).pressed.connect(_on_player_pressed.bind(i))


func _on_player_spell_attempt_use(user : int, spell : Spell):
	_current_user = user;
	_current_spell = spell;


func _on_player_selected(id : int):
	var entity_data = DataManager.party_data[id];
	var entity_id = entity_data.id;
	var entity = DataManager.entity_database.get_entity(entity_id);
	 
	preview_image.texture = ResourceLoader.load(entity.entity_sprites[3], "Texture2D") as Texture2D;
	
	if _current_index != id :
		preview_image.get_node("TweenPlayerUI").play_tween_name("Zap");
	_current_index = id;
	
	var hp_mod = _current_spell.cast_overworld(_current_user, id, true);
	
	var hp = entity.get_hp(entity_data.level);
	
	var current_weapon = DataManager.item_database.get_item(entity_data.weapon_id);
	var current_armor = DataManager.item_database.get_item(entity_data.armor_id);
	var current_accessory = DataManager.item_database.get_item(entity_data.accessory_id);
	var all_equipment = [current_weapon, current_armor, current_accessory];
	
	for e in all_equipment:
		if e != null:
			hp += (e as EquipmentItem).hp_mod;
	
	$"Visuals/Player Info/Bars/HP".set_values_immediate(entity_data.hp_value, 0, hp)
	$"Visuals/Player Info/Bars/HP".set_underlay_value((entity_data.hp_value - hp_mod) as float);
	
	var user_data = DataManager.party_data[_current_user];
	var user_entity = DataManager.entity_database.get_entity(user_data.id);
	
	var user_mp = user_entity.get_mp(user_data.level);
	
	var user_weapon = DataManager.item_database.get_item(user_data.weapon_id);
	var user_armor = DataManager.item_database.get_item(user_data.armor_id);
	var user_accessory = DataManager.item_database.get_item(user_data.accessory_id);
	var user_equipment = [user_weapon, user_armor, user_accessory];
	
	for e in user_equipment:
		if e != null:
			user_mp += (e as EquipmentItem).mp_mod;
	
	mp_bar_current.set_values_immediate(user_data.mp_value - _current_spell.spell_cost, 0, user_mp, true)
	mp_bar_current.set_underlay_value(user_data.mp_value);
	
	if id == _current_user:
		hp_bar_current.set_values_immediate(entity_data.hp_value, 0, hp)
		hp_bar_current.set_underlay_value((entity_data.hp_value - hp_mod) as float);
	else:
		hp_bar_current.set_underlay_value((user_data.hp_value) as float)


func _on_player_pressed(id : int):
	var spell_used = false;
	
	var current_selection = UIManager.current_selection;
	UIManager.suspend_selection(true);
	
	if ! _current_spell.check_can_cast_overworld(_current_user, id) :
		$"Visuals/Description".text = tr("T_ITEM_DESCRIPTION_NO_EFFECT");
	else :
		# TODO: Does not handle status conditions properly. Applies to items as well
		var result = _current_spell.cast_overworld(_current_user, id);
		spell_used = true;
		
		DataManager.party_data[id].hp_value -= result;
		DataManager.party_data[_current_user].mp_value -= _current_spell.spell_cost;
		
		# Play animation(s)
		$"Visuals/Description".text = "";
		$"Visuals/Player Info/Bars/HP".set_value(DataManager.party_data[id].hp_value);
		
		mp_bar_current.set_value(DataManager.party_data[_current_user].mp_value);
		
		if id == _current_user:
			hp_bar_current.set_value(DataManager.party_data[id].hp_value);
		
		await get_tree().create_timer(0.5).timeout;
		
		# Display restore message
		if result != 0 : 
			$"Visuals/Description".text = tr("T_ITEM_DESCRIPTION_HP_RESTORE").format({hp = str(abs(result))});
	
	_awaiting_input = true;
	while _awaiting_input :
		await get_tree().process_frame;
	
	UIManager.suspend_selection(false);
	current_selection.grab_focus();
	$"Visuals/Description".text = tr("T_PARTY_DESCRIPTION_USE_SPELL");
	
	if DataManager.party_data[_current_user].mp_value < _current_spell.spell_cost:
		UIManager.close_menu_name(self.menu_name);


func on_menu_inactive():
	super.on_menu_inactive();
	
	var user_data = DataManager.party_data[_current_user];
	var user_entity = DataManager.entity_database.get_entity(user_data.id);
	
	var user_hp = user_entity.get_hp(user_data.level);
	var user_mp = user_entity.get_mp(user_data.level);
	
	var user_weapon = DataManager.item_database.get_item(user_data.weapon_id);
	var user_armor = DataManager.item_database.get_item(user_data.armor_id);
	var user_accessory = DataManager.item_database.get_item(user_data.accessory_id);
	var user_equipment = [user_weapon, user_armor, user_accessory];
	
	for e in user_equipment:
		if e != null:
			user_hp += (e as EquipmentItem).hp_mod;
			user_mp += (e as EquipmentItem).mp_mod;
	
	hp_bar_current.set_values_immediate(user_data.hp_value, 0, user_hp)
	hp_bar_current.set_underlay_value((user_data.hp_value) as float);
	
	mp_bar_current.set_values_immediate(user_data.mp_value, 0, user_mp)
	mp_bar_current.set_underlay_value((user_data.mp_value) as float);


func _unhandled_input(event):
	if !_awaiting_input : return;
	
	if (event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_cancel")):
		accept_event();
		_awaiting_input = false


func _exit_tree() :
	if EventManager != null :
		EventManager.on_player_spell_attempt_use.disconnect(_on_player_spell_attempt_use);
