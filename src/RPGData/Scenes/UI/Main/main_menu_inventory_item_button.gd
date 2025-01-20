extends Button


func refresh_data(data):
	text = tr(DataManager.item_database.get_item(data).item_name_key);
