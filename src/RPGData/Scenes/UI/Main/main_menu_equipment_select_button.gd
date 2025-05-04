extends Button

func refresh_data(data):
	if data is Item :
		if data == null : text = "-";
		else : text = tr(data.item_name_key);
	else : text = "-";
