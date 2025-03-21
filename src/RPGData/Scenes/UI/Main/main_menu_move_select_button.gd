extends Button

func refresh_data(data):
	if data is Spell :
		if data == null : text = "-";
		else : text = tr(data.spell_name_key);
	else : text = "-";
