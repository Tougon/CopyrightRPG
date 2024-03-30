extends EntityBase
class_name EntityParticle

@onready var particle : GPUParticles2D = $GPUParticles2D;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instance the sprite's material
	particle.restart();
