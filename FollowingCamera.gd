@tool
extends Camera3D

@onready
var car1: CarRigidBody = get_parent().get_parent().get_parent().get_parent().get_node("Car/%CarRigidBody")
@onready
var car2: CarRigidBody = get_parent().get_parent().get_parent().get_parent().get_node("Car2/%CarRigidBody")

var car = null

@export
var playerIndex = 1

func _ready():
	set_physics_process(true)
# 	pass

func _physics_process(delta):
	if car == null:
		if playerIndex == 1:
			car = car1
		else:
			car = car2
	else:
		var car_pos = car.global_transform.origin
		var car_y = car.global_transform.basis.y
		var car_z = car.global_transform.basis.z

		var target = car_pos + car_y * 3 + car_z * -4

		# position = target
		# tween.tween_property(self, "position", target, 0.2)

		position = lerp(position, target, 20 * delta)

		look_at(car_pos + Vector3.UP * 2, Vector3.UP)
		# var fromSelfToCar = car_pos - position

		# var targetRotation = fromSelfToCar.orthonormalized()

		# rotation = lerp(rotation, fromSelfToCar, 10 * delta)
