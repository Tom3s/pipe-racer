extends Node

class_name InputHandlerNew

var car: RigidBody3D
var player_prefix: String = "p1_"
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

func _physics_process(delta):
	car.driftInput = driftInput
	car.steeringInput = steerInput
	for tire in tires:
		var targetRotation = steerInput * car.getSteeringFactor()
		tire.targetRotation = targetRotation
	
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

