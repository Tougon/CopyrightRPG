extends CanvasLayer

@export var tween_player : TweenPlayer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.on_player_take_damage.connect(_on_player_take_damage);


func _on_player_take_damage(defeated : bool, crit : bool):
	# TODO: Make this more intense if player is defeated
	tween_player.play_tween_name("Damage");


func _on_destroy():
	if EventManager != null:
		EventManager.on_player_take_damage.disconnect(_on_player_take_damage);