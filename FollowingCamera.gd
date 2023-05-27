extends Camera3D

@onready
var car: CarRigidBody = get_parent().get_node("Car/%CarRigidBody")


func _process(delta):
	var car_pos = car.global_transform.origin
	var car_y = car.global_transform.basis.y
	var car_z = car.global_transform.basis.z

	var target = car_pos + car_y * 2 + car_z * -4

	# position = target
	# tween.tween_property(self, "position", target, 0.2)

	position = lerp(position, target, 0.2)

	look_at(car_pos + Vector3.UP * 1.5, Vector3.UP)
		
