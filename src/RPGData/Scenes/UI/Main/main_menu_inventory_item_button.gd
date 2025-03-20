extends Button


func refresh_data(data):
	if data is int:
		text = tr(DataManager.item_database.get_item(data).item_name_key);
