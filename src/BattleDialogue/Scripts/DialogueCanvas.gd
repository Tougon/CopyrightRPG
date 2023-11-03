extends CanvasLayer

class_name DialogueCanvas

signal on_dialogue_complete();

enum PrintType { CHARACTER, WORD, SYLLABLE }

@export_group("References")
@export var text_label : RichTextLabel;
@export_group("Appearance")
@export var max_rows : int = 2;
@export var character_pause : float = 0.1;
@export var word_pause : float = 0.15;
@export var row_pause : float = 0.3;
@export var row_display_time : float = 3.0;
@export var dialogue_end_time : float = 1.0;
@export var print_type : PrintType;
@export var print_delay_type : PrintType;
@export var capitalize : bool = true;
var current_rows : int;

var bbcode : String = "[bgcolor=000000D5][indent]"; 
var test_text : String = "NOT EVEN A DISTANT LAND WE'RE STUCK ON A WHOLE DIFFERENT PLANET. NO PEACE LOOKING AT THE SKY TROUBLE'S ALWAYS ALL AROUND SO WE STAY QUICK WITH THE GUNS AND CANNONS. STANDING AS LONG AS WE CAN UNTIL WE GET ALL DOLLS OFF THEN CALL OUR BETS OFF WE'LL BLOW THROUGH YOUR TAR, DEALING WITH LIFE'S MESSED UP";

# Called when the node enters the scene tree for the first time.
func _ready():
	text_label.clear();
	EventManager.on_dialogue_queue.connect(_on_dialogue_queue);
	await get_tree().process_frame;
	text_label.append_text(bbcode);

func _on_dialogue_queue(dialogue : String):
	if capitalize: dialogue = dialogue.to_upper();
	
	var sequence = DialogueSequence.new(get_tree(), self, dialogue);
	EventManager.on_sequence_queue.emit(sequence);


func print_dialogue(text : String):
	
	if text_label.get_parsed_text().length() > 1:
		text_label.add_text("\n");
	
	match print_type:
		PrintType.WORD:
			_print_by_word(text);
		PrintType.SYLLABLE:
			_print_by_word(text);
		PrintType.CHARACTER:
			_print_by_character(text);


func _print_by_character(text : String):
	var current_line : String;
	
	for chr in text:
		
		if chr == " ":
			text_label.add_text(chr)
			current_line += chr;
			continue;
		
		# Check if the width will exceed the line
		var width = text_label.get_theme_font("font").get_string_size(("[indent]" + current_line + chr).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, text_label.get_theme_font_size("normal_font_size")).x;
		
		# If the width exceeds the limit add a new line before continuing
		if width >= text_label.get_rect().size.x:
			await get_tree().create_timer(row_pause).timeout;
			text_label.add_text("\n");
			_row_display_delay(current_line);
			
			# If the number of lines are too great, immediately remove the first line
			if text_label.get_paragraph_count() > (max_rows + 1):
				text_label.remove_paragraph(1);
			current_line = "";
		
		var pause_time = character_pause;
		text_label.add_text(chr);
		current_line += (chr);
		
		await get_tree().create_timer(pause_time).timeout;
	
	_row_display_delay(current_line);
	await get_tree().create_timer(dialogue_end_time).timeout;
	on_dialogue_complete.emit();


func _print_by_word(text : String):
	var splits = text.split(" ");
	var current_line : String;
	
	for n in splits.size():
		# Get the word at the current index
		var word = splits[n];
		
		# Check if the width will exceed the line
		var width = text_label.get_theme_font("font").get_string_size(("[indent]" + current_line + word).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, text_label.get_theme_font_size("normal_font_size")).x;
		
		var pause_time = word_pause;
		
		match print_delay_type:
			
			PrintType.WORD:
				pause_time = character_pause * word.length();
		
		# If the width exceeds the limit add a new line before continuing
		if width >= text_label.get_rect().size.x:
			if n < splits.size() - 1:
				await get_tree().create_timer(row_pause).timeout;
				text_label.add_text("\n");
				_row_display_delay(current_line);
			
			# If the number of lines are too great, immediately remove the first line
			if text_label.get_paragraph_count() > (max_rows + 1):
				text_label.remove_paragraph(1);
			current_line = "";
		else:
			if n > 0:
				text_label.add_text(" ");
		
		text_label.add_text(word);
		current_line += (word + " ");
		
		await get_tree().create_timer(pause_time).timeout;
	
	_row_display_delay(current_line);
	await get_tree().create_timer(dialogue_end_time).timeout;
	on_dialogue_complete.emit();


func _row_display_delay(row : String):
	# Clean up spaces
	row = row.replace(" ", "");
	
	# Wait for the max display time
	await get_tree().create_timer(row_display_time).timeout;
	
	var current_display = text_label.get_parsed_text().split("\n");
	var to_remove = -1;
	var row_num = 0;
	var removed = false;
	
	text_label.clear();
	text_label.append_text(bbcode);
	
	for n in current_display.size():
		
		var line = current_display[n].replace("\t", "").replace(" ", "");
		
		if line == row:
			to_remove = n+1;
			continue;
			
		if row_num > 0:
			text_label.add_text("\n");
		text_label.add_text(current_display[n].replace("\t", ""));
		row_num += 1;


func _on_destroy():
	if EventManager != null:
		EventManager.on_dialogue_queue.disconnect(_on_dialogue_queue);
