extends Node

var raycasts: Array = []
var car: CarRigidBody

func _ready():
	raycasts.push_back(%FrontLeftRayCast)
	raycasts.push_back(%FrontRightRayCast)
	car = %CarRigidBody

func _input(event):
	var steering = Input.get_axis("turn_right", "turn_left")
	for raycast in raycasts:
		var targetRotation = Vector3.UP * steering * car.STEERING
		raycast.targetRotation = targetRotation
	
	var acceleration = Input.get_axis("accelerate", "break")
	car.accelerationInput = -acceleration

	if event.is_action_pressed("respawn"):
		car.respawn()
		print("respawned")

