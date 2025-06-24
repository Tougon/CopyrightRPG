extends RadialCarouselItem


func set_data(obj) :
	if obj is Spell:
		$Label.text = tr((obj as Spell).spell_name_key);
	else:
		$Label.text = tr("T_ITEM_NAME_NONE");


# Input/Selection
func set_highlight(active : bool) :
	if active :
		$TweenPlayerUI.play_tween_name("Highlight");
	else :
		$TweenPlayerUI.play_tween_name("Unhighlight");
