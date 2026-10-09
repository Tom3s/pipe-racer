extends Camera3D
class_name FollowingCamera

var car: CarController = null

var shouldUpdatePosition = false

var portalTransitionActive := false
var portalEntryTransform := Transform3D.IDENTITY
var portalExitTransform := Transform3D.IDENTITY
var portalEntrySide := 0.0
var dopplerResumeFrames := 0

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
	car.teleported.connect(onCarTeleported)
	changeCullMask(car.playerIndex)

func setup(carReference):
	car = carReference
	car.changeCameraMode.connect(changeMode)
	car.playerIndexChanged.connect(changeCullMask)
	car.teleported.connect(onCarTeleported)
	changeCullMask(car.playerIndex)

func _ready():
	doppler_tracking = Camera3D.DOPPLER_TRACKING_PHYSICS_STEP
	fov = 65
	set_physics_process(true)

func _physics_process(delta):
	if car == null:
		return
	if car.paused && !shouldUpdatePosition:
		_updateDopplerReset()
		return

	var cameraPositionBeforeUpdate := global_position
	var trackedCarTransform := getTrackedCarTransform()
	var car_pos = trackedCarTransform.origin
	var car_y = trackedCarTransform.basis.y
	var car_z = trackedCarTransform.basis.z
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
	
	if portalTransitionActive && hasCrossedPortal(cameraPositionBeforeUpdate, global_position):
		completePortalTransition()

	shouldUpdatePosition = false
	_updateDopplerReset()

func forceUpdatePosition():
	portalTransitionActive = false
	_suspendDoppler()
	shouldUpdatePosition = true

func onCarTeleported(entryTransform: Transform3D, exitTransform: Transform3D, entrySide: float) -> void:
	portalEntryTransform = entryTransform
	portalExitTransform = exitTransform
	portalEntrySide = entrySide

	if is_zero_approx(portalEntrySide):
		portalEntrySide = signf((portalEntryTransform.affine_inverse() * global_transform).origin.z)

	portalTransitionActive = true
	var currentSide := signf((portalEntryTransform.affine_inverse() * global_transform).origin.z)
	if is_zero_approx(currentSide) || (!is_zero_approx(portalEntrySide) && currentSide != portalEntrySide):
		completePortalTransition()

func getTrackedCarTransform() -> Transform3D:
	if !portalTransitionActive:
		return car.global_transform

	return portalEntryTransform * portalExitTransform.affine_inverse() * car.global_transform

func hasCrossedPortal(previousPosition: Vector3, currentPosition: Vector3) -> bool:
	var previousOffset := portalEntryTransform.affine_inverse() * previousPosition
	var currentOffset := portalEntryTransform.affine_inverse() * currentPosition

	if is_zero_approx(portalEntrySide):
		return previousOffset.z * currentOffset.z <= 0.0

	var previousSide := signf(previousOffset.z)
	var currentSide := signf(currentOffset.z)
	return is_zero_approx(currentSide) || (previousSide == portalEntrySide && currentSide != portalEntrySide)

func completePortalTransition() -> void:
	global_transform = portalExitTransform * portalEntryTransform.affine_inverse() * global_transform
	portalTransitionActive = false
	_suspendDoppler()

func _suspendDoppler() -> void:
	doppler_tracking = Camera3D.DOPPLER_TRACKING_DISABLED
	dopplerResumeFrames = 2

func _updateDopplerReset() -> void:
	if dopplerResumeFrames <= 0:
		return

	dopplerResumeFrames -= 1
	if dopplerResumeFrames == 0:
		doppler_tracking = Camera3D.DOPPLER_TRACKING_PHYSICS_STEP

func changeMode():
	mode = (mode + 1) % 3
	shouldUpdatePosition = true
	if car.playerIndex < 4:
		GlobalProperties.PREFERED_CAMERAS[car.playerIndex] = mode

func changeCullMask(playerIndex: int):
	cull_mask = 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128
	cull_mask -= 2 ** (playerIndex + 1)

	# this layer renders portals
	set_cull_mask_value(16, true)
