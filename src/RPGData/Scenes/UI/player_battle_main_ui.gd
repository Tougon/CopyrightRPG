extends MenuPanel
var current_entity : EntityController;


# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.set_active_player.connect(_set_active_entity);
	super._ready();


func on_tween_end_active(tween_name : String):
	super.on_tween_end_active(tween_name);
	
	var msg = tr("T_BATTLE_TURN_READY").format({entity = current_entity.param.entity_name});
	EventManager.on_message_queue.emit(msg);


func _set_active_entity(entity : EntityController):
	current_entity = entity;
