extends Node3D
@onready
var car: CarController = null

var mode2D: bool = false

@onready var impactSounds: AudioStreamPlayer3D = %Impact
@onready var impactSounds2D: AudioStreamPlayer = %Impact_2D

func _ready():
	car = get_parent()

	car.body_entered.connect(func(_a):
		playImpact()
		car.state.resetImpactTimer()
	)

func playImpact(_body: Node = null):
	if mode2D:
		impactSounds2D.play(0.15)
	else:
		impactSounds.play(0.15)

func set2DAudio():
	mode2D = true