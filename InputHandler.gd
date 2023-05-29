extends Node

class_name InputHandler

var raycasts: Array = []
var car: CarRigidBody
var player_prefix: String = "p1_"

func _ready():
	raycasts.push_back(%FrontLeftRayCast)
	raycasts.push_back(%FrontRightRayCast)
	car = %CarRigidBody

func _input(event):
	var steering = Input.get_axis(player_prefix + "turn_right", player_prefix + "turn_left")
	car.steeringInput = steering
	for raycast in raycasts:
		var targetRotation = Vector3.UP * steering * car.get_steering_factor()
		raycast.targetRotation = targetRotation
	
	var acceleration = Input.get_axis(player_prefix + "accelerate", player_prefix + "break")
	car.accelerationInput = -acceleration

	if event.is_action_pressed(player_prefix + "respawn"):
		car.respawn()

func set_input_player(player: int):
	player_prefix = "p" + str(player) + "_"

