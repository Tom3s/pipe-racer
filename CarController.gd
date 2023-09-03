extends RigidBody3D

class_name CarController

@export
var springConstant: float = 150

@export 
var springDamping: float = 100

@export
var springRestLength: float = 0.25

@export
var springBottomOut: float = 0.1

@export
var respawnPosition: Vector3 = Vector3.ZERO

@export
var respawnRotation: Vector3 = Vector3.ZERO

@export
var maxSteeringAngle: float = PI/3

@export
var tireGrip: float = 0.85

@export
var driftFactor: float = 0.3

@export
var acceleration: float = 20

@export
var brakingMultiplier: float = 2.0

@export
var passiveBraking: float = 2.0


@export
var downforceMinimunSpeed: float = 40

@export
var downforceMaximumSpeed: float = 80

@export
var downForce: float = 40

var tireRadius: float = 0.375
var shouldRespawn: bool = false

@export
var jumpingForceReduction: float = 0.02

@export
var lowerSpeedLimit: float = 3.0

# input vars
var accelerationInput: float = 0.0
var steeringInput: float = 0.0
var driftInput: float = 0.0

var inputHandler: InputHandlerNew

var pauseLinearVelocity: Vector3
var pauseAngularVelocity: Vector3

var paused: bool = false

var shouldPause: bool = false

var initialRespawn: bool = false

# ingameData
var playerName: String = ""
@export
var playerIndex: int = 0:
	set(newIndex):
		playerIndex = onInputPlayerIndexChanged(newIndex)
	get:
		return playerIndex

func onInputPlayerIndexChanged(newIndex: int) -> int:
	%InputHandler.setInputPlayer(newIndex + 1)
	return newIndex

@export
var frameColor: Color = Color.PINK:
	set(newColor):
		frameColor = onFrameColorChanged(newColor)
	get:
		return frameColor

func onFrameColorChanged(newColor: Color) -> Color:
	var rollcage: MeshInstance3D = get_node("%CarModel/%Rollcage")
	rollcage.set_surface_override_material(0, rollcage.get_surface_override_material(0).duplicate())
	rollcage.get_surface_override_material(0).set("albedo_color", newColor)
	return newColor

var state: CarStateMachine

# SIGNALS

signal respawned(playerIndex: int)
signal finishedRace(playerIndex: int)
signal isReady(playerIndex: int)
signal isResetting(playerIndex: int, resetting: bool)







func setup(
		playerData: PlayerData, 
		newPlayerIndex: int, 
		startingPosition: Dictionary, 
		checkpointCount: int, 
		nrLaps: int
):
	playerIndex = newPlayerIndex
	playerName = playerData.PLAYER_NAME
	frameColor = playerData.PLAYER_COLOR

	state.prepareCheckpointList(checkpointCount)
	state.nrLaps = nrLaps
	state.placement = playerIndex + 1

	setRespawnPositionFromDictionary(startingPosition)
	respawn(true)

func reset(startingPosition: Dictionary, checkpointCount: int) -> void:
	state.reset(checkpointCount, playerIndex)

	setRespawnPositionFromDictionary(startingPosition)
	respawn(true)

func _ready():
	inputHandler = %InputHandler
	state = %CarStateMachine
	set_physics_process(true)

func _physics_process(_delta):
	applyDownforce(state.getGroundedTireCount())
	
	if state.isAirborne():
		applyAirPitch()
		applyAirSteering()
		slidingFactor = 1
		
	# if getSpeed() < lowerSpeedLimit && !accelerationInput:
	# 	linear_velocity *= Vector3.UP
	
	
	
	if shouldPause && !paused:
		pauseLinearVelocity = linear_velocity
		pauseAngularVelocity = angular_velocity
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

		if initialRespawn:
			global_position = respawnPosition
			global_rotation = respawnRotation
			pauseLinearVelocity = Vector3.ZERO
			pauseAngularVelocity = Vector3.ZERO
			respawned.emit(playerIndex)
			initialRespawn = false
		paused = true
		freeze = true
	elif !shouldPause && paused:
		freeze = false
		linear_velocity = pauseLinearVelocity
		angular_velocity = pauseAngularVelocity
		paused = false


func _integrate_forces(physicsState):
	if shouldRespawn:
		physicsState.linear_velocity = Vector3.ZERO
		physicsState.angular_velocity = Vector3.ZERO
		physicsState.transform = createRespawnTransform3D()
		shouldRespawn = false
		if initialRespawn:
			# initialRespawn = false
			pauseMovement()
		respawned.emit(playerIndex)

func createRespawnTransform3D():
	var tempTransform = Transform3D()
	tempTransform = tempTransform.rotated(Vector3.UP, respawnRotation.y)
	tempTransform = tempTransform.rotated(Vector3.FORWARD, respawnRotation.x)
	tempTransform = tempTransform.rotated(Vector3.RIGHT, respawnRotation.z)
	tempTransform.origin = respawnPosition
	return tempTransform
@export
var airPitchControl: float = 8

@export
var airYawControl: float = 8

func applyAirPitch():
	var pitch = - accelerationInput * airPitchControl * mass
	apply_torque(global_transform.basis.x * pitch)

func applyAirSteering():
	var yaw = steeringInput * airYawControl * mass
	apply_torque(global_transform.basis.y * yaw)

func applyDownforce(groundedTireCount: float):
	var downforceFactor = remap(getForwardSpeed(), downforceMinimunSpeed, downforceMaximumSpeed, 0, 1)
	downforceFactor = clampf(downforceFactor, 0.0, 1.0)
	
	var groundedTireRatio = groundedTireCount / 4.0
	
	apply_central_force(-global_transform.basis.y * downforceFactor * downForce * groundedTireRatio * mass)

func get_point_velocity (point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_transform.origin)

func applySuspension(raycastDistance: float, springDirection: Vector3, tireVelocity: Vector3, suspensionPoint: Vector3, delta: float):
	
	var forcePosition = suspensionPoint - global_position
#	if raycastDistance - tireRadius <= springBottomOut:
#		var offset = (springBottomOut) - (raycastDistance - tireRadius)
#		var velocity = springDirection.dot(tireVelocity)
#		var forceMagnitude = (offset * springConstant * 3 * mass) - (velocity * springDamping * 2)
#		var force = forceMagnitude * springDirection #* mass
#
#		apply_force(force, forcePosition)
		

	var offset = (springRestLength + tireRadius) - raycastDistance
	var velocity = springDirection.dot(tireVelocity)
	var forceMagnitude = (offset * springConstant * mass) - (velocity * springDamping )
	var force = forceMagnitude * springDirection #* mass
	
	# if state.aboutToJump():
	# 	force *= jumpingForceReduction
	# DebugDraw.draw_arrow_ray(suspensionPoint, force, force.length(), Color.DARK_CYAN, 0.02)

	apply_force(force, forcePosition)

func applyBottomedOutSuspension(raycastDistance: float, springDirection: Vector3, tireVelocity: Vector3, suspensionPoint: Vector3, delta: float):
	var offset = (springBottomOut) - (raycastDistance)
#	if offset < 0:
#		return
	var velocity = springDirection.dot(tireVelocity)
	var forceMagnitude = (offset * springConstant * 10 * mass) - (velocity * springDamping * 1.5)
	var force = forceMagnitude * springDirection #* mass

	apply_force(force, suspensionPoint - global_position)

@export
var skiddingTreshold: float = 0.05

@export
var gripDecayRate: float = 0.05

@export
var slidingFactor: float = 0

@export
var regripFactor: float = 0.08

func calculateSlipAngle(tireVelocity: Vector3, tireForwardDirection: Vector3):
	var normalizedTireVelocity = tireVelocity.normalized()
	var normalizedTireForwardDirection = tireForwardDirection.normalized()
	
	var dotProduct = normalizedTireVelocity.dot(normalizedTireForwardDirection)
	
	return acos(abs(dotProduct))


func calculate_tire_grip(slipAngle: float):
	if slidingFactor <= driftInput:
		slidingFactor = driftInput
	else:
		var positiveSlipAngle = abs(slipAngle)
#		var lerpWeight = -(2 * positiveSlipAngle) / PI + 1 # linear decay according to slip angle
		var lerpWeight = (-(2 * positiveSlipAngle) / PI + 1) ** 5 # non-linear decay according to slip angle
#		print('Slip angle: ', positiveSlipAngle)
#		print('Lerp Weight: ', lerpWeight)
		slidingFactor = lerp(slidingFactor, driftInput, lerpWeight * regripFactor)
		if slidingFactor <= skiddingTreshold:
			slidingFactor = 0
#		slidingFactor = 0
	
	var driftMultiplier = remap(slidingFactor, 0, 1, 1, driftFactor)
	
#	var skiddingRatio = getSkiddingRatio()
#	var skidMultiplier = clampf(1 / (1 - skiddingTreshold + skiddingRatio), 0.0, 1.0)
	var skidMultiplier = clampf(exp(-gripDecayRate * slipAngle ** 2), 0.0, 1.0)
	
	return tireGrip * driftMultiplier * skidMultiplier

func applyFriction(steeringDirection: Vector3, tireVelocity: Vector3, tireMass: float, contactPoint: Vector3, frictionMultiplier: float):
	var steeringVelocity = steeringDirection.dot(tireVelocity)
#	var tireGripFactor = calculate_tire_grip(getTireSkidRatio(contactPoint, steeringDirection))
	var tireGripFactor = calculate_tire_grip(calculateSlipAngle(tireVelocity, steeringDirection.rotated(Vector3.UP, -PI/2))) * frictionMultiplier

	
	var desiredVelocityChange = -steeringVelocity * tireGripFactor

	var desiredAcceleration = desiredVelocityChange * 120 #delta

	var force = steeringDirection * desiredAcceleration * tireMass
	
	# DebugDraw.draw_arrow_ray(contactPoint, force, force.length(), Color.DARK_MAGENTA, 0.02)
	
	if state.aboutToJump():
		force *= jumpingForceReduction
	
	apply_force(force, contactPoint - global_position)

func applyAcceleration(accelerationDirection: Vector3, tireVelocity: Vector3, contactPoint: Vector3, accelerationMultiplier: float):
	if accelerationInput == 0:
		var tireAxisVelocity = accelerationDirection.dot(tireVelocity)
		var desiredVelocityChange = - tireAxisVelocity * passiveBraking

		var desiredAcceleration = desiredVelocityChange

		var force = accelerationDirection * desiredAcceleration #* mass
		
		# DebugDraw.draw_arrow_ray(contactPoint, force, force.length(), Color.DARK_GREEN, 0.02)
		
		apply_force(force, contactPoint - global_position)
		return

	var force = accelerationDirection * accelerationInput * acceleration * mass * accelerationMultiplier

	if force.dot(linear_velocity) < 0:
		force *= brakingMultiplier
	
	# DebugDraw.draw_arrow_ray(contactPoint, force, force.length(), Color.DARK_GREEN, 0.02)
	
	
	apply_force(force, contactPoint - global_position)

func getSpeed() -> float:
	var velocityForward = global_transform.basis.z.dot(linear_velocity)
	var velocityRight = global_transform.basis.x.dot(linear_velocity)

	return Vector2(velocityForward, velocityRight).length()

func getSteeringFactor() -> float:
	var g = func(x): return (- x / 150) + 1
	var f = func(x): return max(g.call(x), 0.25)

	return f.call(getSpeed()) * maxSteeringAngle

func getForwardSpeed() -> float:
	var speed = linear_velocity.dot(global_transform.basis.z)
	
	if speed < 0:
		speed = 0
	
	return speed

func setRespawnPosition(newPosition: Vector3, newRotation: Vector3):
	respawnPosition = newPosition
	respawnRotation = newRotation

func setRespawnPositionFromDictionary(newPosition: Dictionary):
	respawnPosition = newPosition["position"]
	respawnRotation = newPosition["rotation"]

func respawn(initial: bool = false):
	shouldRespawn = true
	pauseAngularVelocity = Vector3.ZERO
	pauseLinearVelocity = Vector3.ZERO
	print('Reset paused velocity')
	initialRespawn = initial

func getSkiddingRatio():
	var skiddinForward = linear_velocity.dot(global_transform.basis.z)
	var skiddingSideways = linear_velocity.dot(global_transform.basis.x)
	
	var skiddingRatio = skiddingSideways / skiddinForward
	
	return abs(skiddingRatio) if !is_nan(skiddingRatio) else 0.0


func getTireSkidRatio(tirePosition: Vector3, sidewaysDirecion: Vector3):
	
	var skiddinForward = get_point_velocity(tirePosition).dot(sidewaysDirecion.rotated(Vector3.UP, PI/2))
	var skiddingSideways = get_point_velocity(tirePosition).dot(sidewaysDirecion)
	
	var skiddingRatio = skiddingSideways / skiddinForward
	
	return abs(skiddingRatio) if !is_nan(skiddingRatio) else 0.0
	

@export
var soundSpeedLimit: float = 1.0

@export
var gear6Speed: float = 150
	
func getPitchScale():
	return max(0, remap(getSpeed(), soundSpeedLimit, gear6Speed, 1, 4))

func getPlayingIdle():
	return getSpeed() < soundSpeedLimit

func pauseMovement():
	shouldPause = true
	print('pause movement')

func resumeMovement():
	shouldPause = false
	print('unpause movement')

func startRace():
	resumeMovement()
	state.currentLap = 0
	state.hasControl = true


func resetInputs():
	accelerationInput = 0.0
	steeringInput = 0.0
	driftInput = 0.0

# DEBUG FUNCTIONS

func debugSkiddingRatio():
	var text = "Sliding Factor: "
	text += str(slidingFactor)
	return text
