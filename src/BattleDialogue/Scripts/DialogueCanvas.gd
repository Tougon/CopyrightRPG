extends CanvasLayer

class_name DialogueCanvas

signal on_dialogue_print();
signal on_dialogue_complete();
signal on_dialogue_removed();
signal on_set_dialogue_end_pos(pos : Vector2);

enum PrintType { CHARACTER, WORD, SYLLABLE }

@export_group("References")
@export var text_label : RichTextLabel;
@export_group("Appearance")
@export var max_rows : int = 2;
@export var character_pause : float = 0.1;
@export var word_pause : float = 0.15;
@export var row_pause : float = 0.3;
@export var expire_rows : bool = true;
@export var row_display_time : float = 3.0;
@export var dialogue_end_time : float = 1.0;
@export var print_type : PrintType;
@export var print_delay_type : PrintType;
@export var capitalize : bool = true;

var is_printing : bool = false;
# Used if dialogue sequence should await a keypress to advance
var await_key : bool = false;
var finish_print : bool = false;
var current_rows : int;

var interval_timer = Timer.new();
var row_timer = Timer.new();
var end_timer = Timer.new();

@export var bbcode : String = "[bgcolor=000000D5]"; 
var test_text : String = "NOT EVEN A DISTANT LAND WE'RE STUCK ON A WHOLE DIFFERENT PLANET. NO PEACE LOOKING AT THE SKY TROUBLE'S ALWAYS ALL AROUND SO WE STAY QUICK WITH THE GUNS AND CANNONS. STANDING AS LONG AS WE CAN UNTIL WE GET ALL DOLLS OFF THEN CALL OUR BETS OFF WE'LL BLOW THROUGH YOUR TAR, DEALING WITH LIFE'S MESSED UP";

var horizontal_padding : int;
var vertical_padding : int;
var line_separation : int;

# Called when the node enters the scene tree for the first time.
func _ready():
	current_rows = 0;
	text_label.clear();
	on_dialogue_print.emit();
	
	self.add_child(interval_timer);
	self.add_child(row_timer);
	self.add_child(end_timer);
	
	interval_timer.one_shot = true;
	row_timer.one_shot = true;
	end_timer.one_shot = true;
	
	EventManager.on_dialogue_queue.connect(_on_dialogue_queue);
	EventManager.on_message_queue.connect(_on_message_queue);
	await get_tree().process_frame;
	
	text_label.autowrap_mode = TextServer.AUTOWRAP_OFF;
	text_label.append_text(bbcode);
	
	if text_label.theme:
		horizontal_padding = text_label.get_theme_constant("text_highlight_h_padding", "RichTextLabel");
		vertical_padding = text_label.get_theme_constant("text_highlight_v_padding", "RichTextLabel");
		line_separation = text_label.get_theme_constant("line_separation", "RichTextLabel");
		
		if BattleManager.dialogue_canvas == null:
			BattleManager.dialogue_canvas = self;


func _on_dialogue_queue(dialogue : String):
	if capitalize: dialogue = dialogue.to_upper();
	
	var sequence = DialogueSequence.new(get_tree(), self, dialogue);
	EventManager.on_sequence_queue.emit(sequence);


func _on_message_queue(dialogue : String):
	if capitalize: dialogue = dialogue.to_upper();
	
	var sequence = DialogueSequence.new(get_tree(), self, dialogue, true);


func clear_dialogue():
	current_rows = 0;
	text_label.clear();
	text_label.append_text(bbcode);
	on_dialogue_print.emit();


func print_dialogue(text : String, await_key : bool = false):
	on_dialogue_print.emit();
	self.await_key = await_key;
	current_rows += 1;
	
	if text_label.get_parsed_text().length() > 1:
		text_label.add_text("\n");
		
		if current_rows > max_rows:
			_remove_extra_rows();
	
	is_printing = true;
	
	match print_type:
		PrintType.WORD:
			_print_by_word(text);
		PrintType.SYLLABLE:
			_print_by_word(text);
		PrintType.CHARACTER:
			_print_by_character(text);


func skip_dialogue_to_end():
	finish_print = true;
	interval_timer.timeout.emit();
	row_timer.timeout.emit();
	end_timer.timeout.emit();


func _print_by_character(text : String):
	var current_line : String;
	
	for chr in text:
		
		if chr == " ":
			text_label.add_text(chr)
			current_line += chr;
			continue;
		
		# Check if the width will exceed the line
		var width = text_label.get_theme_font("normal_font", "RichTextLabel").get_string_size(("[indent]" + current_line + chr).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, text_label.get_theme_font_size("normal_font_size")).x;
		
		# If the width exceeds the limit add a new line before continuing
		if width >= text_label.get_rect().size.x:
			var row_pause_time = row_pause;
			if finish_print :
				row_timer.start(row_pause_time);
				await row_timer.timeout;
			
			text_label.add_text("\n");
			_row_display_delay(current_line);
			
			# If the number of lines are too great, immediately remove the first line
			if text_label.get_paragraph_count() > (max_rows + 1):
				text_label.remove_paragraph(1);
			current_line = "";
		
		var pause_time = character_pause;
		text_label.add_text(chr);
		current_line += (chr);
		
		if !finish_print :
			interval_timer.start(pause_time);
			await interval_timer.timeout;
	
	_row_display_delay(current_line);
	
	var end_time = dialogue_end_time;
	if !finish_print:
		end_timer.start(end_time);
		await end_timer.timeout;
	
	on_dialogue_complete.emit();
	is_printing = false;
	finish_print = false;


func _print_by_word(text : String):
	var splits = text.split(" ");
	var current_line : String;
	
	for n in splits.size():
		# Get the word at the current index
		var word = splits[n];
		
		# Check if the width will exceed the line
		var text_pos = text_label.get_theme_font("normal_font", "RichTextLabel").get_string_size("" + (current_line + word).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, text_label.get_theme_font_size("normal_font_size"));
		
		var pause_time = word_pause;
		
		match print_delay_type:
			
			PrintType.WORD:
				pause_time = character_pause * word.length();
		
		var added_space = false;
		
		# If the width exceeds the limit add a new line before continuing
		if text_pos.x >= text_label.get_rect().size.x:
			current_rows += 1;
			
			if n < splits.size():
				var row_pause_time = row_pause;
				
				if !finish_print && row_pause_time > 0 : 
					row_timer.start(row_pause_time);
					await row_timer.timeout;
				
				text_label.add_text("\n");
				if expire_rows:
					_row_display_delay(current_line);
			
			# If the number of lines are too great, immediately remove the first line
			if current_rows > max_rows:
				_remove_extra_rows();
			current_line = "";
			text_pos = text_label.get_theme_font("normal_font", "RichTextLabel").get_string_size("" + (current_line + word).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, text_label.get_theme_font_size("normal_font_size"));
		else:
			if n > 0:
				text_label.add_text(" ");
				added_space = true;
		
		text_label.add_text(word);
		current_line += (word + " ");
		
		var row_index = current_rows - 1;
		var offset = Vector2(text_pos.x + horizontal_padding, (text_pos.y * row_index) + (line_separation * row_index));
		offset.x += (text_label.get_parent().position.x);
		offset.y -= vertical_padding;
		on_set_dialogue_end_pos.emit(offset);
		
		if n < splits.size() - 1 && !finish_print && pause_time > 0:
			interval_timer.start(pause_time);
			await interval_timer.timeout;
	
	if expire_rows :
		_row_display_delay(current_line);
	
	var end_time = dialogue_end_time;
	if !finish_print && end_time > 0:
		end_timer.start(end_time);
		await end_timer.timeout;
	
	on_dialogue_complete.emit();
	is_printing = false;
	finish_print = false;


func _get_current_text() -> String:
	
	var current_display = text_label.get_parsed_text().split("\n");
	var result = "[indent]";
	
	for n in current_display.size():
		
		if n > 0:
			result += "\n";
			
		result += (current_display[n].replace("\t", ""));
	
	return result;


func _remove_extra_rows():
	
	var current_display = text_label.get_parsed_text().split("\n");
	
	current_rows = 0;
	text_label.clear();
	text_label.append_text(bbcode);
	on_dialogue_print.emit();
	
	while current_display.size() > max_rows:
		current_display.remove_at(0);
	
	for n in current_display.size():
		
		if n > 0:
			text_label.add_text("\n");
		
		var line = current_display[n].replace("\t", "");
		text_label.add_text(line);
		current_rows += 1;


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
		if line == row && to_remove == -1:
			to_remove = n+1;
			current_rows -= 1;
			continue;
			
		if row_num > 0:
			text_label.add_text("\n");
		text_label.add_text(current_display[n].replace("\t", ""));
		row_num += 1;
		
		if n == current_display.size() - 1:
			var text_pos = text_label.get_theme_font("normal_font", "RichTextLabel").get_string_size(current_display[n].replace("\t", "").to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, text_label.get_theme_font_size("normal_font_size"));
			var row_index = current_rows - 1;
			var offset = Vector2(text_pos.x + horizontal_padding, (text_pos.y * row_index) + (line_separation * row_index));
			offset.x += (text_label.get_parent().position.x);
			offset.y -= vertical_padding;
			on_set_dialogue_end_pos.emit(offset);
	
	if current_rows == 0:
		on_dialogue_print.emit();


func _on_destroy():
	if EventManager != null:
		EventManager.on_dialogue_queue.disconnect(_on_dialogue_queue);
	
	if BattleManager != null && BattleManager.dialogue_canvas == self:
		BattleManager.dialogue_canvas = null;
