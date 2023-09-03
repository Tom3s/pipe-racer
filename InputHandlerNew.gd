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

# func _physics_process(delta):
# 	car.driftInput = driftInput
# 	car.steeringInput = steerInput
# 	for tire in tires:
# 		var targetRotation = steerInput * car.getSteeringFactor()
# 		tire.targetRotation = targetRotation
	
# 	car.accelerationInput = -accelerationInput

# func _unhandled_input(event):
# 	steerInput = Input.get_axis(playerPrefix + "turn_right", playerPrefix + "turn_left")
# 	accelerationInput = Input.get_axis(playerPrefix + "accelerate", playerPrefix + "break")
# 	respawnInput = event.is_action_pressed(playerPrefix + "respawn")
# 	driftInput = Input.get_action_strength(playerPrefix + "drift")

# 	if respawnInput:
# 		car.respawn()
func _physics_process(delta):
	if !car.state.hasControl:
		tires[0].targetRotation = 0
		tires[1].targetRotation = 0
		return
	steerInput = Input.get_axis(playerPrefix + "turn_right", playerPrefix + "turn_left")
	car.driftInput = Input.get_action_strength(playerPrefix + "drift")
	car.steeringInput = steerInput
	for tire in tires:
		var targetRotation = steerInput * car.getSteeringFactor()
		tire.targetRotation = targetRotation
	
	car.accelerationInput = -Input.get_axis(playerPrefix + "accelerate", playerPrefix + "break")

	if Input.is_action_just_pressed(playerPrefix + "respawn"):
		car.respawn()
	if Input.is_action_just_pressed(playerPrefix + "ready"):
		car.state.setReadyTrue()
	if Input.is_action_just_pressed(playerPrefix + "reset"):
		car.state.setResetting()

# func _unhandled_input(event):
# 	steerInput = Input.get_axis(playerPrefix + "turn_right", playerPrefix + "turn_left")
# 	accelerationInput = Input.get_axis(playerPrefix + "accelerate", playerPrefix + "break")
# 	respawnInput = event.is_action_pressed(playerPrefix + "respawn")
# 	driftInput = Input.get_action_strength(playerPrefix + "drift")

# 	if respawnInput:
# 		car.respawn()


func setInputPlayer(player: int):
	playerPrefix = "p" + str(player) + "_"

