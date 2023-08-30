extends Camera3D
class_name FollowingCamera

var car = null

var shouldUpdatePosition = false

func _init(carReference):
	car = carReference

func _ready():
	doppler_tracking = Camera3D.DOPPLER_TRACKING_PHYSICS_STEP
	set_physics_process(true)

func _physics_process(delta):
	if car.paused && !shouldUpdatePosition:
		return

	var car_pos = car.global_transform.origin
	var car_y = car.global_transform.basis.y
	var car_z = car.global_transform.basis.z

	var target = car_pos + car_y * 3 + car_z * -4

	# if shouldUpdatePosition:
	# 	print("Force update camera position")
	# 	global_position = target
	# 	look_at(car_pos + Vector3.UP * 2, Vector3.UP)
	# 	# shouldUpdatePosition = false
	# 	return

	global_position = lerp(global_position, target, 25 * delta if !shouldUpdatePosition else 1)

	look_at(car_pos + Vector3.UP * 2, Vector3.UP)

	shouldUpdatePosition = false

func forceUpdatePosition():
	shouldUpdatePosition = true