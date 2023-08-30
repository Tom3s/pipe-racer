extends Camera3D
class_name FollowingCamera

var car = null

func _init(carReference):
	car = carReference

func _ready():
	doppler_tracking = Camera3D.DOPPLER_TRACKING_PHYSICS_STEP
	set_physics_process(true)

func _physics_process(delta):
	if car.paused:
		return


	var car_pos = car.global_transform.origin
	var car_y = car.global_transform.basis.y
	var car_z = car.global_transform.basis.z

	var target = car_pos + car_y * 3 + car_z * -4

	position = lerp(position, target, 25 * delta)

	look_at(car_pos + Vector3.UP * 2, Vector3.UP)
	