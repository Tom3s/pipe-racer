extends Node3D
@onready
var car: CarRigidBody = null

var impactSounds = []

# Called when the node enters the scene tree for the first time.
func _ready():
	impactSounds.push_back(%Impact1)
	impactSounds.push_back(%Impact2)

	car = get_parent()

	car.body_entered.connect(playImpact)


func playImpact(_body: Node):
	print("impact")
	var sound = impactSounds.pick_random()

	sound.pitch_scale = randf_range(0.8, 1.2)
	sound.play(0.15)
