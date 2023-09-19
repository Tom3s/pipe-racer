extends Node

class_name InputHandlerNew

var car: CarController
# var playerPrefix: String = "p1_"
var allowedPrefixes: Array = ["p1_", "p2_", "p3_", "p4_"]
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

func _physics_process(_delta):
	if allowedPrefixes.size() == 1:
		handleSingleInput(allowedPrefixes[0])
	else:
		handleMultiInput()

func handleSingleInput(playerPrefix):
	if Input.is_action_just_pressed(playerPrefix + "ready"):
		car.state.setReadyTrue()
	if Input.is_action_just_pressed(playerPrefix + "reset"):
		car.state.setResetting()
	if Input.is_action_just_pressed(playerPrefix + "change_camera_mode"):
		car.changeCameraMode.emit()

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

var multiReady = false
var multiReset = false
var multiChangeCameraMode = false
var multiSteerInput = 0
var multidriftInput = 0
var multiAccelerationInput = 0
var multiRespawnInput = false

func handleMultiInput():
	multiReady = false
	multiReset = false
	multiChangeCameraMode = false
	multiSteerInput = 0
	multidriftInput = 0
	multiAccelerationInput = 0
	multiRespawnInput = false

	for prefix in allowedPrefixes:
		multiReady = multiReady || Input.is_action_just_pressed(prefix + "ready")
		multiReset = multiReset || Input.is_action_just_pressed(prefix + "reset")
		multiChangeCameraMode = multiChangeCameraMode || Input.is_action_just_pressed(prefix + "change_camera_mode")

		steerInput = Input.get_axis(prefix + "turn_right", prefix + "turn_left")
		if abs(multiSteerInput) < abs(steerInput):
			multiSteerInput = steerInput
		
		multidriftInput = max(multidriftInput, Input.get_action_strength(prefix + "drift"))
		
		accelerationInput = -Input.get_axis(prefix + "accelerate", prefix + "break")
		if abs(multiAccelerationInput) < abs(accelerationInput):
			multiAccelerationInput = accelerationInput
		
		multiRespawnInput = multiRespawnInput || Input.is_action_just_pressed(prefix + "respawn")
	
	if multiReady:
		car.state.setReadyTrue()
	if multiReset:
		car.state.setResetting()
	if multiChangeCameraMode:
		car.changeCameraMode.emit()

	if !car.state.hasControl:
		tires[0].targetRotation = 0
		tires[1].targetRotation = 0
		return

	car.driftInput = multidriftInput
	car.steeringInput = multiSteerInput
	for tire in tires:
		var targetRotation = multiSteerInput * car.getSteeringFactor()
		tire.targetRotation = targetRotation
	
	car.accelerationInput = multiAccelerationInput

	if multiRespawnInput:
		car.respawn()

func setInputPlayers(players: Array[int]):
	# playerPrefix = "p" + str(player) + "_"
	allowedPrefixes.clear()
	for player in players:
		allowedPrefixes.append("p" + str(player) + "_")

