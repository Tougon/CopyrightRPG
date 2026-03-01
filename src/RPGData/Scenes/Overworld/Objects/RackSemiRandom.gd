extends Node2D

@export var seed : int;
@export var use_index_as_seed : bool = true;

@export var items : Array[Sprite2D];
@export var textures : Array[Texture2D];
@export var colors : Array[Color];

@export_range(1, 10) var visibility_chance : int = 2; 

func _ready() :
	if items.size() == 0 || colors.size() == 0 :
		return;
	
	var current = seed;
	if use_index_as_seed : current = get_index();
	
	for item in items :
		
		if item != null :
			current = rand_from_seed(current)[0];
			item.visible = current % visibility_chance != 0;
			
			current = rand_from_seed(current)[0];
			item.texture = textures[current % textures.size()];
			
			current = rand_from_seed(current)[0];
			item.modulate = colors[current % colors.size()];
