@tool
class_name DialogicBeginBattleEvent
extends DialogicEvent

## Event that waits for input before continuing.

var encounter := "";
var cancel_dialogue_on_defeat := true;
var delay := 0.5;

################################################################################
## 						EXECUTE
################################################################################

func _execute() -> void:
	dialogic.Text.hide_textbox()
	dialogic.Portraits.leave_all_characters();
	dialogic.current_state = DialogicGameHandler.States.IDLE
	dialogic.Inputs.auto_skip.enabled = false
	await dialogic.get_tree().create_timer(delay).timeout
	
	# Load encounter
	var data = load(encounter);
	if data != null && data is Encounter:
		EventManager.on_battle_queue.emit(data);
		EventManager.on_battle_end.connect(_on_battle_end);
	else : 
		print("ERROR: Battle does not exist!");
		finish()

func _on_battle_end(result : BattleResult):
	EventManager.on_battle_end.disconnect(_on_battle_end);
	print("Battle Done")
	
	if cancel_dialogue_on_defeat && !result.victory:
		dialogic.end_timeline();
		return;
	
	await EventManager.overworld_battle_fade_completed;
	print("Faded in")
	finish()

################################################################################
## 						INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Begin Battle"
	set_default_color('Color1')
	event_category = "RPG"
	event_sorting_index = 50


################################################################################
## 						SAVING/LOADING
################################################################################

func get_shortcode() -> String:
	return "begin_battle"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"path"		: {"property": "encounter", 	"default": ""},
		"cancel_dialogue"		: {"property": "cancel_dialogue_on_defeat", 	"default": true},
		"delay"		: {"property": "delay", 	"default": 0.5},
	}


func build_event_editor() -> void:
	add_header_label('Begin Battle')
	add_body_edit('encounter', ValueType.FILE, {
			'left_text'		: 'Encounter',
			'file_filter' 	: "*.tres; Supported Files",
			'placeholder' 	: "None" })
	add_body_edit('cancel_dialogue_on_defeat', ValueType.BOOL, {
			'left_text'		: 'Cancel Dialogue on Defeat'})
	add_body_edit('delay', ValueType.NUMBER, {
			'left_text'		: 'Delay'})
