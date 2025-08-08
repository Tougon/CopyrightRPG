extends Resource

class_name FieldEffect

@export_group("Field Effect Parameters")

## Indicates if this effect can stack
@export var stackable : bool = false;
## Used to identify instances of the effect internally
@export var effect_name : String = "";
# Turn limit applied to instances of this effect. Generally only used for displays.
@export_range(-1, 20) var turn_limit : int = 5;

# TODO: Field Effects will NOT affect a revived entity. 
# Revival hasn't been implemented yet so this is fine for now.
@export var on_activate : Array[FieldEffectFunction]
@export var on_stack : Array[FieldEffectFunction]
@export var on_deactivate : Array[FieldEffectFunction]

func create_instance() -> FieldEffectInstance:
	var inst = FieldEffectInstance.new();
	inst.effect = self;
	inst.turns_active = 0;
	return inst;

func activate(players : Array[EntityController], enemies : Array[EntityController]):
	for effect in on_activate :
		effect.execute(self, players, enemies);

func stack(players : Array[EntityController], enemies : Array[EntityController]):
	for effect in on_stack :
		effect.execute(self, players, enemies);

func deactivate(players : Array[EntityController], enemies : Array[EntityController]):
	for effect in on_deactivate :
		effect.execute(self, players, enemies);
