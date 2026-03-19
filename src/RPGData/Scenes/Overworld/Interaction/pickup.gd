extends Interactable

@export var item_ids : Array[int];
@export var randomize : bool = false;
@export var repeatable : bool = false;
@export var empty_dialogue : String = "generic_pickup_empty";

var _items_to_award : Array[int];

func interact():
	# Fail if item has already been picked up and not repeatable
	if !repeatable && DataManager.current_save.pickups.has(_get_pickup_code()) :
		default_dialogue = empty_dialogue;
		additional_dialogue.clear();
		super.interact();
	
	# Fetch the item name and prepare pickups
	var dialogue_output : String;
	_items_to_award.clear()
	
	for i in item_ids.size() :
		var item = DataManager.item_database.get_item(item_ids[i]);
		var item_name = tr(item.item_name_key);
		
		dialogue_output += GrammarManager.get_indirect_article(item_name).to_lower() + "[color=FFFF00]" + item_name + "[/color]";
		
		if i + 1 < item_ids.size() :
			dialogue_output += ", ";
		
		if !randomize : 
			_items_to_award.append(item_ids[i]);
	
	if randomize :
		_items_to_award.append(item_ids.pick_random());
	
	Dialogic.VAR.item_name = dialogue_output;
	Dialogic.timeline_ended.connect(_check_item_award);
	
	super.interact();


func _check_item_award():
	Dialogic.timeline_ended.disconnect(_check_item_award);
	
	if Dialogic.VAR.award_item :
		for item in _items_to_award :
			DataManager.change_item_amount(item, 1);
		
		DataManager.current_save.pickups.append(_get_pickup_code());
		Dialogic.VAR.award_item = false;


func _get_pickup_code() -> String :
	return SceneManager.current_scene_path + "/" + object_id;
