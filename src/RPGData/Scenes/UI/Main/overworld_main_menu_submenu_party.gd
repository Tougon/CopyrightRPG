extends OverworldSubmenu

#@export_group("Stat Info")

var _current_player_index = 0;


func _ready():
	super._ready();
	
	_set_entity_info(0);


func set_active(state : bool):
	super.set_active(state);


# Party menu functions
func _set_entity_info(index : int):
	if index < 0 : index = DataManager.party_data.size() - 1;
	elif index >= DataManager.party_data.size() : index = 0;
	_current_player_index = index;
	
	# Get and calculate entity data
	var player = DataManager.party_data[index];
	var entity = DataManager.entity_database.get_entity(player.id, true);
	
	var hp = entity.get_hp(player.level);
	var mp = entity.get_mp(player.level);
	var atk = entity.get_atk(player.level);
	var def = entity.get_def(player.level);
	var mag = entity.get_sp_atk(player.level);
	var res = entity.get_sp_def(player.level);
	var spd = entity.get_spd(player.level);
	var lck = entity.get_lck(player.level);
	
	# TODO: Animate portrait and name
	$"Entity Stats Area/Entity Portrait Group/Portrait/TweenPlayerUI".play_tween_name("Portrait Zap");
	
	if entity.entity_sprites.size() > 3:
		$"Entity Stats Area/Entity Portrait Group/Portrait".texture = ResourceLoader.load(entity.entity_sprites[3], "Texture2D") as Texture2D;
	$"Entity Stats Area/Entity Portrait Group/Name/Label".text = tr(entity.name_key);
	$"Entity Stats Area/Entity Stats Group/Level/HBoxContainer/Value".text = str(player.level);
	
	$"Entity Stats Area/Entity Stats Group/HP/Label".text = tr("T_HP") + ": " + str(hp - player.hp_dmg) + "/" + str(hp);
	$"Entity Stats Area/Entity Stats Group/HP".value = ((hp as float) - (player.hp_dmg as float)) / (hp as float)
	$"Entity Stats Area/Entity Stats Group/MP/Label".text = tr("T_MP") + ": " + str(mp - player.mp_dmg) + "/" + str(mp);
	$"Entity Stats Area/Entity Stats Group/MP".value = ((mp as float) - (player.mp_dmg as float)) / (mp as float)
	
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/ATK".set_stat_value(atk);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/DEF".set_stat_value(def);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/MAG".set_stat_value(mag);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/RES".set_stat_value(res);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/SPD".set_stat_value(spd);
	$"Entity Stats Area/Entity Stats Group/Stats/GridContainer/LCK".set_stat_value((lck * GameplayConstants.LUCK_SCALE));


# UI utility functions
func on_focus():
	super.on_focus();
	await get_tree().process_frame;


func _on_focus_entered_next():
	_set_entity_info(_current_player_index + 1);
	UIManager.previous_selection.grab_focus();


func _on_focus_entered_previous():
	_set_entity_info(_current_player_index - 1);
	UIManager.previous_selection.grab_focus();


func on_ui_trigger_l():
	_set_entity_info(_current_player_index - 1);


func on_ui_trigger_r():
	_set_entity_info(_current_player_index + 1);


func cache_menu_state():
	pass;


func _exit_tree() :
	pass;
