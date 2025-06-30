extends Button


func refresh_data(data):
	if data is int:
		text = tr(DataManager.item_database.get_item(data).item_name_key);
		
		var amount = DataManager.get_item_amount(data);
		
		if amount > 1 :
			$Quantity.text = "x" + str(amount);
		else :
			$Quantity.text = "";
