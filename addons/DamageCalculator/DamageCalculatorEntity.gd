@tool
extends VBoxContainer
class_name DamageCalculatorEntity

var entity_list : Array[Entity];
var damage_calc : DamageCalculator;

var current_index : int;
var current_level : int;
var current_aux_stat_1 : int;
var current_aux_stat_2 : int;

@export var attacker : bool = true;


func initialize(source : DamageCalculator, entities : Array[Entity]) :
	damage_calc = source;
	
	entity_list = entities;
	var current_index = $"Entity Select".get_item_index($"Entity Select".get_selected_id());
	$"Entity Select".clear();
	
	for entity in entity_list :
		if !entity.final : continue;
		
		var entity_name = TranslationServer.get_translation_object("en").get_message(entity.name_key);
		if entity_name.is_empty() : entity_name = entity.resource_name;
		
		$"Entity Select".add_item(entity_name);
	
	if current_index < entity_list.size() && current_index != -1:
		$"Entity Select".select(current_index);
	else :
		$"Entity Select".select(0);
	
	current_index = $"Entity Select".get_item_index($"Entity Select".get_selected_id());
	_on_entity_select_item_selected(current_index);


func _update_visuals():
	if attacker : 
		$Label.text = "Attacker";
		
		$"Aux Stat 1".text = "ATK ("
		if $"Aux Stat Slider 1".value < 0 : $"Aux Stat 1".text += ""
		else : $"Aux Stat 1".text += "+"
		$"Aux Stat 1".text += (str($"Aux Stat Slider 1".value) + ")");
		
		$"Aux Stat 2".text = "MAG ("
		if $"Aux Stat Slider 2".value < 0 : $"Aux Stat 2".text += ""
		else : $"Aux Stat 2".text += "+"
		$"Aux Stat 2".text += (str($"Aux Stat Slider 2".value) + ")");
	else :
		$Label.text = "Defender";
		
		$"Aux Stat 1".text = "DEF ("
		if $"Aux Stat Slider 1".value < 0 : $"Aux Stat 1".text += ""
		else : $"Aux Stat 1".text += "+"
		$"Aux Stat 1".text += (str($"Aux Stat Slider 1".value) + ")");
		
		$"Aux Stat 2".text = "RES ("
		if $"Aux Stat Slider 2".value < 0 : $"Aux Stat 2".text += ""
		else : $"Aux Stat 2".text += "+"
		$"Aux Stat 2".text += (str($"Aux Stat Slider 2".value) + ")");
	
	if damage_calc != null : damage_calc.refresh_display();


func _on_entity_select_item_selected(index: int) -> void:
	var entity = entity_list[index];
	current_index = index;
	
	$"Level Slider".min_value = entity.min_level;
	$"Level Slider".max_value = entity.max_level;
	
	var current_level = $"Level Slider".value;
	if current_level > entity.max_level : current_level = entity.max_level;
	if current_level < entity.min_level : current_level = entity.min_level;
	
	$Level.text = "Level (" + str(current_level) + ")";
	$"Level Slider".set_value_no_signal(current_level);
	current_level = roundi($"Level Slider".value);
	current_aux_stat_1 = roundi($"Aux Stat Slider 1".value);
	current_aux_stat_2 = roundi($"Aux Stat Slider 2".value);
	
	var param = entity.create_entity_params(current_level);
	
	$GridContainer/HP.text = "HP: " + str(param.entity_hp);
	$GridContainer/MP.text = "MP: " + str(param.entity_mp);
	$GridContainer/ATK.text = "ATK: " + str(param.entity_atk);
	$GridContainer/DEF.text = "DEF: " + str(param.entity_def);
	$GridContainer/MAG.text = "MAG: " + str(param.entity_sp_atk);
	$GridContainer/RES.text = "RES: " + str(param.entity_sp_def);
	$GridContainer/SPD.text = "SPD: " + str(param.entity_spd);
	$GridContainer/LCK.text = "LCK: " + str(round(param.entity_luck * 25));
	
	if attacker :
		if entity.level_exp != null :
			$EXP.text = "Next Level: "
			if current_level == entity.max_level :
				$EXP.text += "N/A";
			else :
				$EXP.text += str(entity.get_level_exp(current_level));
		else:
			$EXP.text = "---"
	else :
		if entity.reward_exp != null :
			$EXP.text = "Reward EXP: " + str(entity.get_reward_exp(current_level));
		else:
			$EXP.text = "---"
	
	_update_visuals();


func _on_level_slider_changed(value: float) -> void:
	current_level = roundi($"Level Slider".value);
	var current_index = $"Entity Select".get_item_index($"Entity Select".get_selected_id());
	_on_entity_select_item_selected(current_index);


func _on_aux_stat_slider_1_value_changed(value: float) -> void:
	current_aux_stat_1 = roundi($"Aux Stat Slider 1".value);
	var current_index = $"Entity Select".get_item_index($"Entity Select".get_selected_id());
	_on_entity_select_item_selected(current_index);


func _on_aux_stat_slider_2_value_changed(value: float) -> void:
	current_aux_stat_2 = roundi($"Aux Stat Slider 2".value);
	var current_index = $"Entity Select".get_item_index($"Entity Select".get_selected_id());
	_on_entity_select_item_selected(current_index);
