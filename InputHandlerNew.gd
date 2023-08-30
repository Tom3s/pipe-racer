extends Node

class_name InputHandlerNew

var car: CarController
var playerPrefix: String = "p1_"
var tires: Array = []

#@onready
#var synchronizer = %MultiplayerSynchronizer

func _ready():
	tires.push_back(%TireFL)
	tires.push_back(%TireFR)
	car = get_parent()
	set_physics_process(true)

var steerInput = 0
var accelerationInput = 0
var driftInput = 0
var respawnInput = false

var pausedState = false

func _physics_process(delta):
	car.driftInput = driftInput
	car.steeringInput = steerInput
	for tire in tires:
		var targetRotation = steerInput * car.getSteeringFactor()
		tire.targetRotation = targetRotation
	
	car.accelerationInput = -accelerationInput

	# if respawnInput:
	# 	car.respawn()

func _unhandled_input(event):
	steerInput = Input.get_axis(playerPrefix + "turn_right", playerPrefix + "turn_left")
	accelerationInput = Input.get_axis(playerPrefix + "accelerate", playerPrefix + "break")
	respawnInput = event.is_action_pressed(playerPrefix + "respawn")
	driftInput = Input.get_action_strength(playerPrefix + "drift")

	if Input.is_action_just_pressed(playerPrefix + "pause"):
		pausedState = !pausedState
		if pausedState:
			car.pauseMovement()
		else:
			car.unpauseMovement()

	if respawnInput:
		car.respawn()


func setInputPlayer(player: int):
	playerPrefix = "p" + str(player) + "_"

