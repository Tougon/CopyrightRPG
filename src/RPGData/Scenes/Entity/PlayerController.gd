extends EntityController
class_name PlayerController

enum ActionType { ATTACK, DEFEND, SPELL, ITEM }

@export var player_id : int;
@export var default_attack_action : Spell;
@export var default_defend_action : Spell;
@export var default_seal_effect : SealEffectGroup;

var attack_action : Spell;
var defend_action : Spell;
var seal_effect : SealEffectGroup;
var prev_action_type : ActionType;

var default_color : Color;


func _ready():
	super._ready();
	
	EventManager.on_player_items_changed.connect(_on_player_items_changed);
	EventManager.set_player_group_state.connect(_on_player_group_state_changed);


func _on_battle_begin(params : BattleParams):
	super._on_battle_begin(params);
	
	modulate = Color.WHITE;
	sprite.position = _get_sprite_start_position();


func _on_player_group_state_changed(active : bool):
	if active:
		var variance = randf_range(-0.1, 0.1);
		
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		tween.tween_property(sprite, "position", Vector2.ZERO, 0.4 + variance);
		tween.set_ease(Tween.EASE_OUT);
		tween.set_trans(Tween.TRANS_QUART);
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.4 + variance).from(Vector2(1.2,1.2));
		tween.set_ease(Tween.EASE_OUT);
		tween.set_trans(Tween.TRANS_QUART);
	else:
		var tween = get_tree().create_tween();
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.12);
		tween.set_ease(Tween.EASE_OUT);
		tween.set_trans(Tween.TRANS_QUART);


func entity_init(params : BattleParams):
	var hp_mod = 0;
	var mp_mod = 0;
	
	attack_action = default_attack_action;
	defend_action = default_defend_action;
	seal_effect = default_seal_effect;
	
	if params != null:
		# If player is null, they are locked. Do not use this entity.
		if params.players[player_id] == null : 
			visible = false;
			return;
		
		level = params.players[player_id].override_level;
		hp_mod = params.players[player_id].hp_offset;
		mp_mod = params.players[player_id].mp_offset;
	else:
		level = 30;
	
	current_entity = params.players[player_id].override_entity;
	super.entity_init(params)
	
	var weapon = DataManager.item_database.get_item(params.players[player_id].override_weapon_id);
	if weapon != null && weapon is EquipmentItem && (weapon as EquipmentItem).equipment_type == EquipmentItem.EquipmentType.Weapon :
		_apply_equipment(weapon);
	
	var armor = DataManager.item_database.get_item(params.players[player_id].override_armor_id);
	if armor != null && armor is EquipmentItem && (armor as EquipmentItem).equipment_type == EquipmentItem.EquipmentType.Armor :
		_apply_equipment(armor);
	
	var accessory = DataManager.item_database.get_item(params.players[player_id].override_accessory_id);
	if accessory != null && accessory is EquipmentItem && (accessory as EquipmentItem).equipment_type == EquipmentItem.EquipmentType.Accessory :
		_apply_equipment(accessory);
	
	current_hp = hp_mod;
	current_mp = mp_mod;
	
	
	# Override move list with player's set
	if params.players[player_id].override_move_list != null && params.players[player_id].override_move_list.size() > 0:
		move_list = params.players[player_id].override_move_list;
	
	await get_tree().process_frame;
	EventManager.register_player.emit(self);
	
	await get_tree().create_timer(1.0).timeout
	#TweenExtensions.shake_position_2d($Sprite2D, 0.28, 35, Vector2(50, 0), Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.35);


func _apply_equipment(equipment : EquipmentItem):
	max_hp += equipment.hp_mod;
	max_mp += equipment.mp_mod;
	param.entity_atk += equipment.atk_mod;
	param.entity_def += equipment.def_mod;
	param.entity_sp_atk += equipment.mag_mod;
	param.entity_sp_def += equipment.res_mod;
	param.entity_spd += equipment.spd_mod;
	param.entity_luck += equipment.lck_mod;
	
	# Originally this offset HP but this was due to how HP used to be stored.
	# Don't do this.
	#current_hp += equipment.hp_mod;
	#current_mp += equipment.mp_mod;
	
	# Apply effects
	for effect in equipment.equipment_effects:
		var inst = effect.create_effect_instance(self, self, null);
		inst.check_success();
		
		if inst.cast_success: 
			inst.on_activate();


func execute_turn_start_effects():
	super.execute_turn_start_effects();
	
	if current_item != null : add_item(current_item);


func create_item_list():
	if player_id == 0 :
		item_list.clear();
		
		# Fetch player items from inventory, P1 only
		var items = DataManager.get_battle_items();
		
		for id in items.keys():
			item_list[DataManager.item_database.get_item(id)] = items[id];
		
		EventManager.on_player_items_changed.emit(item_list, null);


# Item Functions
func consume_item(item : Item = null):
	super.consume_item(item);
	
	EventManager.on_player_item_consumed.emit(current_item);
	EventManager.on_player_items_changed.emit(item_list, current_item);


func add_item(item : Item):
	super.add_item(item);
	EventManager.on_player_items_changed.emit(item_list, item);


func subtract_item(item : Item):
	super.subtract_item(item);
	EventManager.on_player_items_changed.emit(item_list, item);


func _on_player_items_changed(items : Dictionary, delta : Item):
	item_list = items;


# Misc Functions
func on_damage(crit : bool):
	super.on_damage(crit);
	# replace false with if alive
	EventManager.on_player_take_damage.emit(false, crit, current_action == defend_action);


func _on_defeat_complete():
	super._on_defeat_complete();
	EventManager.on_player_defeated.emit(self as EntityController);

func _get_sprite_start_position() -> Vector2:
	var center = get_viewport().get_visible_rect().size / 2.0;
	var direction = (center - position).normalized();
	
	return position - (direction * 300);


func _on_destroy():
	super._on_destroy();
	
	if EventManager != null:
		EventManager.on_player_items_changed.disconnect(_on_player_items_changed);
		EventManager.set_player_group_state.disconnect(_on_player_group_state_changed);
