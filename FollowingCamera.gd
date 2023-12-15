extends Camera3D
class_name FollowingCamera

var car: CarController = null

var shouldUpdatePosition = false

@export
var mode: int = 0

@export
var insideX: float = 0.0

@export
var insideY: float = 1.13

@export
var insideZ: float = 0.15

@export
var insideTilt: float = 1.12

@export
var mode3distance: float = 5.0

func _init(carReference):
	car = carReference
	car.changeCameraMode.connect(changeMode)
	car.playerIndexChanged.connect(changeCullMask)
	changeCullMask(car.playerIndex)

func setup(carReference):
	car = carReference
	car.changeCameraMode.connect(changeMode)
	car.playerIndexChanged.connect(changeCullMask)
	changeCullMask(car.playerIndex)

func _ready():
	doppler_tracking = Camera3D.DOPPLER_TRACKING_PHYSICS_STEP
	fov = 65
	set_physics_process(true)

func _physics_process(delta):
	if car == null:
		return
	if car.paused && !shouldUpdatePosition:
		return

	var car_pos = car.global_transform.origin
	var car_y = car.global_transform.basis.y
	var car_z = car.global_transform.basis.z
	fov = 65
	if shouldUpdatePosition:
		print("Force update camera position")
		global_position = car_pos + car_y * 3 + car_z * -4
		shouldUpdatePosition = false

	if mode == 0:

		var target = car_pos + car_y * 3 + car_z * -4


		global_position = lerp(global_position, target, 25 * delta if !shouldUpdatePosition else 1)

		look_at(car_pos + Vector3.UP * 2, Vector3.UP)
	elif mode == 1:
		global_position = car_pos + car_y * insideY + car_z * insideZ 
		look_at(car_pos + car_y * insideTilt + car_z, car_y)
	elif mode == 2:
		var direction = (global_position - (car_pos + car_y * 2.75)).normalized()
		global_position = (car_pos + car_y * 2.75) + direction * (mode3distance + (car.getSpeed() / 120))

		fov += car.getSpeed() / 25

		# global_position += car_y * 2.0

		look_at(car_pos + Vector3.UP * 2, Vector3.UP)
	

	shouldUpdatePosition = false

func forceUpdatePosition():
	shouldUpdatePosition = true

func changeMode():
	mode = (mode + 1) % 3
	shouldUpdatePosition = true
	if car.playerIndex < 4:
		GlobalProperties.PREFERED_CAMERAS[car.playerIndex] = mode

func changeCullMask(playerIndex: int):
	cull_mask = 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128
	cull_mask -= 2 ** (playerIndex + 1)
