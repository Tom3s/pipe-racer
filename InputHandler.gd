extends Node

class_name InputHandler

var raycasts: Array = []
var car: CarRigidBody
var player_prefix: String = "p1_"

@onready
var synchronizer = %MultiplayerSynchronizer

func _ready():
	raycasts.push_back(%FrontLeftRayCast)
	raycasts.push_back(%FrontRightRayCast)
	car = get_parent()
	set_physics_process(true)

var steerInput = 0
var accelerationInput = 0
var driftInput = 0
var respawnInput = false

func _physics_process(delta):
	if synchronizer.is_multiplayer_authority() or get_tree().get_multiplayer().is_server():
		if car.timeTrialState == car.TimeTrialState.COUNTDOWN || car.timeTrialState == car.TimeTrialState.FINISHED:
			return
		car.driftInput = driftInput
		car.steeringInput = steerInput
		for raycast in raycasts:
			var targetRotation = Vector3.UP * steerInput * car.get_steering_factor()
			raycast.targetRotation = targetRotation
		
		car.accelerationInput = -accelerationInput

		if respawnInput:
			car.respawn()

func _unhandled_input(event):
	steerInput = Input.get_axis(player_prefix + "turn_right", player_prefix + "turn_left")
	accelerationInput = Input.get_axis(player_prefix + "accelerate", player_prefix + "break")
	respawnInput = event.is_action_pressed(player_prefix + "respawn")
	driftInput = Input.get_action_strength(player_prefix + "drift")

func set_input_player(player: int):
	player_prefix = "p" + str(player) + "_"

