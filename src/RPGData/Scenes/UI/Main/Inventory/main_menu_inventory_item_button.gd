extends Button


func refresh_data(data):
	if data is int:
		var item = DataManager.item_database.get_item(data);
		
		if item != null :
			var item_name = tr(item.item_name_key);
			
			if item is MoveItem :
				item_name = item_name.replace("[NAME]", tr((item as MoveItem).move.spell_name_key));
			
			text = item_name;
			
			var amount = DataManager.get_item_amount(data);
			
			if amount > 1 :
				$Quantity.text = "x" + str(amount);
			else :
				$Quantity.text = "";
