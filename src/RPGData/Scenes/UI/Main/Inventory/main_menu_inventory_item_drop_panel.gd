extends MenuPanel


func on_menu_active():
	super.on_menu_active();
	$"../Item Use Panel".visible = false;
	$"../Visuals/Description".text = tr("T_ITEM_DESCRIPTION_DROP_CONFIRM");


func on_menu_inactive():
	EventManager.refresh_current_inventory_item.emit();
	super.on_menu_inactive();
	$"../Item Use Panel".visible = true;


func _on_no_pressed() -> void:
	set_active(false);
