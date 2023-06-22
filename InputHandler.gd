extends Node

class_name InputHandler

var raycasts: Array = []
var tires: Array = []
var car: CarController
var player_prefix: String = "p1_"

func _ready():
	car = get_parent()
	tires.push_back(%TireFL)
	tires.push_back(%TireFR)
	set_physics_process(true)

var steerInput: float = 0
var accelerationInput: float = 0
var driftInput: float = 0
var respawnInput = false

func _physics_process(delta):
	car.driftInput = driftInput
	car.steerInput = steerInput
	
	for tire in tires:
		tire.rotation = steerInput * car.maxSteerAngle * Vector3.RIGHT
	%TireBL.rotation = Vector3.ZERO
	%TireBR.rotation = Vector3.ZERO	
	
	car.accelerationInput = -accelerationInput

	if respawnInput:
		car.respawn()

func _unhandled_input(event):
	steerInput = Input.get_axis(player_prefix + "turn_left", player_prefix + "turn_right")
	accelerationInput = Input.get_axis(player_prefix + "accelerate", player_prefix + "break")
	respawnInput = event.is_action_pressed(player_prefix + "respawn")
	driftInput = Input.get_action_strength(player_prefix + "drift")

func set_input_player(player: int):
	player_prefix = "p" + str(player) + "_"

