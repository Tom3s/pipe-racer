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
var angularTerminalVelocity: float = 0.5

@export
var angularVelocityDamping: float = 0.95

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

@onready var carSynchronizer: CarSynchronizer = %CarSynchronizer
var networkId: int = -1
# ingameData
@export
var playerName: String = "":
	set(newName):
		playerName = newName
		%PlayernameLabel.text = newName
	get:
		return playerName

signal playerIndexChanged(playerIndex: int)
@export
var playerIndex: int = 0:
	set(newIndex):
		playerIndex = onInputPlayerIndexChanged(newIndex)
		%PlayernameLabel.layers = 2 ** (playerIndex + 1)
		playerIndexChanged.emit(playerIndex)
	get:
		return playerIndex

var playerId: String = ""

func onInputPlayerIndexChanged(newIndex: int) -> int:
	# %InputHandler.setInputPlayer(newIndex + 1)
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

signal respawned(playerIndex: int, networkId: int)
signal finishedRace(playerIndex: int, networkId: int)
signal isReady(playerIndex: int, networkId: int)
signal isResetting(playerIndex: int, resetting: bool, networkId: int)
signal changeCameraMode()




var sessionToken: String = ""

func setup(
		playerData: PlayerData, 
		# newPlayerIndex: int, 
		# inputDevices: Array[int],
		checkpointCount: int, 
		nrLaps: int
):
	# playerIndex = newPlayerIndex
	playerName = playerData.PLAYER_NAME
	frameColor = playerData.PLAYER_COLOR
	sessionToken = playerData.SESSION_TOKEN

	# set_multiplayer_authority(playerData.NETWORK_ID)

	state.prepareCheckpointList(checkpointCount)
	state.nrLaps = nrLaps
	state.placement = playerIndex + 1

	# %InputHandler.setInputPlayers(inputDevices)

	# state.hasControl = true


func reset(startingPosition: Dictionary, checkpointCount: int, newLapCount: int = 1) -> void:
	state.reset(checkpointCount, playerIndex, newLapCount)

	setRespawnPositionFromDictionary(startingPosition)
	# respawn()
	respawn(true)

var tires: Array[Tire] = []
var bottomOuts: Array[RayCast3D] = []

func _ready():
	inputHandler = %InputHandler
	state = %CarStateMachine

	tires.push_back(%TireFL)
	tires.push_back(%TireFR)
	tires.push_back(%TireBL)
	tires.push_back(%TireBR)

	bottomOuts.push_back(%BottomOutFL)
	bottomOuts.push_back(%BottomOutFR)
	bottomOuts.push_back(%BottomOutBL)
	bottomOuts.push_back(%BottomOutBR)

	networkId = name.split('_')[0].to_int()

	if networkId == 0:
		networkId = 1

	set_multiplayer_authority(networkId)

	# state.hasControl = true

	set_physics_process(true)

var inFluid: Area3D = null

func _physics_process(_delta):
	# angular_velocity = clamp(angular_velocity, -angularTerminalVelocity * Vector3.ONE, angularTerminalVelocity * Vector3.ONE)
	if angular_velocity.x > angularTerminalVelocity || angular_velocity.x < -angularTerminalVelocity || \
		angular_velocity.y > angularTerminalVelocity || angular_velocity.y < -angularTerminalVelocity || \
		angular_velocity.z > angularTerminalVelocity || angular_velocity.z < -angularTerminalVelocity:
		angular_velocity *= angularVelocityDamping
		
	if !paused && !shouldRespawn:
		for tire in tires:
			calculateTirePhysics(tire, _delta)
		for bottomOut in bottomOuts:
			calculateBottomOutPhysics(bottomOut, _delta)
		
		if inFluid != null:
			calculateBouyancy(_delta)
			var viscosityDamping = remap(inFluid.viscosity, 0, 5, 1.0, 0.9)
			linear_velocity *= viscosityDamping
			angular_velocity *= viscosityDamping

	if is_multiplayer_authority():
		
		if shouldRespawn:
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			global_position = respawnPosition
			global_rotation = respawnRotation

			for tire in tires:
				tire.tireModel.position.y = tire.target_position.y + 0.375
				tire.rotation.y = 0
				tire.smokeEmitter.emitting = false
				tire.dirtEmitter.emitting = false

			shouldRespawn = false
			if initialRespawn:
				# initialRespawn = false
				pauseMovement()
			respawned.emit(playerIndex, networkId)
		else:
			applyDownforce(state.getGroundedTireCount())
			
			if state.isAirborne():
				applyAirPitch()
				applyAirSteering()
				slidingFactor = 0.9
				surfaceFriction = lerp(surfaceFriction, 1.0, 0.01)
		
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
				respawned.emit(playerIndex, networkId)
				initialRespawn = false
			paused = true
			freeze = true
		elif !shouldPause && paused:
			freeze = false
			linear_velocity = pauseLinearVelocity
			angular_velocity = pauseAngularVelocity
			paused = false
		
		carSynchronizer.linear_velocity = linear_velocity
		carSynchronizer.angular_velocity = angular_velocity
		carSynchronizer.global_position = global_position
		carSynchronizer.global_rotation = global_rotation
		carSynchronizer.respawnPosition = respawnPosition
		carSynchronizer.respawnRotation = respawnRotation

		state.impactTimer -= 1

# func _integrate_forces(physicsState):
# 	if shouldRespawn:
# 		physicsState.linear_velocity = Vector3.ZERO
# 		physicsState.angular_velocity = Vector3.ZERO
# 		physicsState.transform = createRespawnTransform3D()
# 		shouldRespawn = false
# 		if initialRespawn:
# 			# initialRespawn = false
# 			pauseMovement()
# 		respawned.emit(playerIndex, networkId)

@export
var steeringSpeed: float = 0.05

@export
var tireRegripSpeed: float = 0.05

var surfaceFriction: float = 1.0
func calculateTirePhysics(tire: Tire, delta):
	# if GlobalProperties.PRECISE_INPUT:
	# 	tire.rotation.y = tire.targetRotation
	# else:
	# 	tire.rotation.y = lerp(tire.rotation.y, tire.targetRotation, steeringSpeed)
	tire.rotation.y = lerp(tire.rotation.y, tire.targetRotation, GlobalProperties.ingameSmoothSteering)
	
	tire.force_raycast_update()

	if tire.is_colliding():
		state.groundedTires[tire.tireIndex] = 1

		var contactPoint = tire.get_collision_point()
		var raycastDistance = (contactPoint - tire.global_position).length()
		# print('Raycast distance: ', raycastDistance)
		# print('Debug: ', (contactPoint - tire.global_position).dot(-global_transform.basis.y))

		var tireVelocitySuspension = get_point_velocity(tire.global_position)

		applySuspension(raycastDistance, tire.global_transform.basis.y, tireVelocitySuspension, tire.global_position, delta)

		var tireVelocityActual = get_point_velocity(contactPoint)

		var collider: Node3D = tire.get_collider().get_parent()
		var frictionMultiplier: float = 1.0
		var accelerationMultiplier: float = 0.0
		var useSmokeParticles: bool = true


		if collider.has_method("getFriction"):
			frictionMultiplier = collider.getFriction()
			accelerationMultiplier = collider.getAccelerationMultiplier()
			useSmokeParticles = collider.getSmokeParticles()
		else:
			frictionMultiplier = 1.0
			accelerationMultiplier = 1.0
			useSmokeParticles = true
		
		if surfaceFriction < frictionMultiplier:
			surfaceFriction = lerp(surfaceFriction, frictionMultiplier, tireRegripSpeed)
		else:
			surfaceFriction = frictionMultiplier
		
		applyFriction(tire.global_transform.basis.x, tireVelocityActual, tire.tireMass, contactPoint, surfaceFriction)

		applyAcceleration(tire.global_transform.basis.z, tireVelocityActual, contactPoint, accelerationMultiplier)

		var tireDistanceTravelled = (tireVelocitySuspension * delta).dot(tire.global_transform.basis.z)

		tire.tireModel.position.y = -raycastDistance + 0.375
		tire.tireModel.rotate_x(tireDistanceTravelled / 0.375)

		tire.smokeEmitter.emitting = slidingFactor > 0.1 && getSpeed() > 15 && useSmokeParticles
		tire.dirtEmitter.emitting = getSpeed() > 15 && !useSmokeParticles
	else:
		state.groundedTires[tire.tireIndex] = 0		
		tire.tireModel.position.y = tire.target_position.y + 0.375
		tire.smokeEmitter.emitting = false
		tire.dirtEmitter.emitting = false

func calculateBottomOutPhysics(bottomOut: RayCast3D, delta):
	bottomOut.force_raycast_update()
	if bottomOut.is_colliding():
		var contactPoint = bottomOut.get_collision_point()
		var raycastDistance = (contactPoint - bottomOut.global_position).length()

		var tireVelocitySuspension = get_point_velocity(bottomOut.global_position)

		applyBottomedOutSuspension(raycastDistance, bottomOut.global_transform.basis.y, tireVelocitySuspension, bottomOut.global_position, delta)

# func createRespawnTransform3D():
# 	var tempTransform = Transform3D()
# 	tempTransform = tempTransform.rotated(Vector3.UP, respawnRotation.y)
# 	tempTransform = tempTransform.rotated(Vector3.FORWARD, respawnRotation.x)
# 	tempTransform = tempTransform.rotated(Vector3.RIGHT, respawnRotation.z)
# 	tempTransform.origin = respawnPosition
# 	return tempTransform
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

func applySuspension(raycastDistance: float, springDirection: Vector3, tireVelocity: Vector3, suspensionPoint: Vector3, _delta: float):
	
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

func applyBottomedOutSuspension(raycastDistance: float, springDirection: Vector3, tireVelocity: Vector3, suspensionPoint: Vector3, _delta: float):
	var offset = (springBottomOut) - (raycastDistance)
#	if offset < 0:
#		return
	var velocity = springDirection.dot(tireVelocity)
	var forceMagnitude = (offset * springConstant * 8 * mass) - (velocity * springDamping * 1.5)
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
	# var normalizedTireVelocity = tireVelocity.normalized()
	# var normalizedTireForwardDirection = tireForwardDirection.normalized()
	
	# var dotProduct = normalizedTireVelocity.dot(normalizedTireForwardDirection)
	
	# return acos(abs(dotProduct))
	return acos(abs(tireVelocity.normalized().dot(tireForwardDirection.normalized())))


func calculate_tire_grip(slipAngle: float):
	if slidingFactor <= driftInput:
		slidingFactor = driftInput
	else:
		# var positiveSlipAngle = abs(slipAngle)
		# var lerpWeight = (-(2 * positiveSlipAngle) / PI + 1) ** 5 # non-linear decay according to slip angle
		var lerpWeight = (-(2 * abs(slipAngle)) / PI + 1) ** 5 # non-linear decay according to slip angle
		slidingFactor = lerp(slidingFactor, driftInput, lerpWeight * regripFactor)
		if slidingFactor <= skiddingTreshold:
			slidingFactor = 0
	
	# var driftMultiplier = remap(slidingFactor, 0, 1, 1, driftFactor)
	# var skidMultiplier = clampf(exp(-gripDecayRate * slipAngle ** 2), 0.0, 1.0)
	# return tireGrip * driftMultiplier * skidMultiplier
	return tireGrip * remap(slidingFactor, 0, 1, 1, driftFactor) * clampf(exp(-gripDecayRate * slipAngle ** 2), 0.0, 1.0)


# preallocating values
var _applyFriction_steeringVelocity: float
var _applyFriction_tireGripFactor: float
var _applyFriction_desiredVelocityChange: float
var _applyFriction_desiredAcceleration: float
var _applyFriction_force: Vector3
func applyFriction(steeringDirection: Vector3, tireVelocity: Vector3, tireMass: float, contactPoint: Vector3, frictionMultiplier: float):
	_applyFriction_steeringVelocity = steeringDirection.dot(tireVelocity)
	_applyFriction_tireGripFactor = calculate_tire_grip(calculateSlipAngle(tireVelocity, steeringDirection.rotated(Vector3.UP, -PI/2))) * frictionMultiplier
	_applyFriction_desiredVelocityChange = -_applyFriction_steeringVelocity * _applyFriction_tireGripFactor
	_applyFriction_desiredAcceleration = _applyFriction_desiredVelocityChange * 120 #delta
	_applyFriction_force = steeringDirection * _applyFriction_desiredAcceleration * tireMass
	
	
	if state.aboutToJump():
		_applyFriction_force *= jumpingForceReduction
	
	apply_force(_applyFriction_force, contactPoint - global_position)

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

# preallocating values
var _getSpeed_velocityForward: float = 0.0
var _getSpeed_velocityRight: float = 0.0
func getSpeed() -> float:
	_getSpeed_velocityForward = global_transform.basis.z.dot(linear_velocity)
	_getSpeed_velocityRight = global_transform.basis.x.dot(linear_velocity)

	return Vector2(_getSpeed_velocityForward, _getSpeed_velocityRight).length()

func getSteeringFactor() -> float:
	var g = func(x): return (- x / 150) + 1.07
	# var f = func(x): return min(max(g.call(x), 0.25), 1.0)
	var h = func(x): return (- x / 60) + 1.2
	var f = func(x): return max(max(g.call(x), 0.25), h.call(x))

	# var l = func(x): return -log(x / 18 + 0.7) + 1.15
	# var f = func(x): return max(l.call(x), 0.25)

	return f.call(getSpeed()) * maxSteeringAngle
	# return max(g.call(getSpeed()), 0.25) * maxSteeringAngle


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
var selfRightingForceCoeff: float = 15

func calculateBouyancy(_delta) -> void:
	var displacedVolume = calculateDisplacedVolume()

	var force: Vector3 = Vector3.ZERO
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	force.y = inFluid.density * gravity * displacedVolume

	apply_central_force(force * _delta)

	# self righting
	var angleDifference = global_rotation.z

	apply_torque(global_transform.basis.z * -angleDifference * _delta * selfRightingForceCoeff * mass)

var collisionPolygonBoundingBox: Vector3 = Vector3.ZERO
var approxVolumeSide: float = 0.0
func calculateDisplacedVolume() -> float:
	# get bounding box
	if collisionPolygonBoundingBox == Vector3.ZERO:
		var collider: CollisionPolygon3D = %Collider

		var minX: float = 10000
		var minY: float = 10000
		var maxX: float = -10000
		var maxY: float = -10000

		for vertex in collider.polygon:
			print('Vertex: ', vertex)
		
			if vertex.x < minX:
				minX = vertex.x
			if vertex.x > maxX:
				maxX = vertex.x
			if vertex.y < minY:
				minY = vertex.y
			if vertex.y > maxY:
				maxY = vertex.y	
		
		var depth = collider.depth

		collisionPolygonBoundingBox = Vector3(
			depth,
			maxY - minY,
			maxX - minX
		)

		var volume = collisionPolygonBoundingBox.x * collisionPolygonBoundingBox.y * collisionPolygonBoundingBox.z
		approxVolumeSide = pow(volume, 1.0/3)

	var xCoverage = getVolumeCoverageOnAxis(
		inFluid.global_position.x,
		inFluid.width,
		global_position.x,
		center_of_mass.x
	)
	var yCoverage = getVolumeCoverageOnAxis(
		inFluid.global_position.y,
		inFluid.height,
		global_position.y,
		center_of_mass.y
	)
	var zCoverage = getVolumeCoverageOnAxis(
		inFluid.global_position.z,
		inFluid.length,
		global_position.z,
		center_of_mass.z
	)

	return xCoverage * yCoverage * zCoverage * collisionPolygonBoundingBox.x * collisionPolygonBoundingBox.y * collisionPolygonBoundingBox.z


func getVolumeCoverageOnAxis(
	fluidPos: float,
	fluidSize: float,
	pos: float,
	centerOfMassOffset: float,
) -> float:
	var xMin = fluidPos
	var xMax = fluidPos + fluidSize
	return max(
		clamp(
			remap(
				pos,
				xMax + approxVolumeSide + centerOfMassOffset,
				xMax - approxVolumeSide + centerOfMassOffset,
				0,
				1
			), 0, 1
		),
		clamp(
			remap(
				pos,
				xMin - approxVolumeSide + centerOfMassOffset,
				xMin + approxVolumeSide + centerOfMassOffset,
				0,
				1
			), 0, 1
		)
	)

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

func getLocalIndex():
	return inputHandler.allowedPrefixes[0][1].to_int() - 1

func getPositionDict() -> Dictionary:
	return {
		"lap": state.currentLap,
		"checkpointCount": state.collectedCheckpointCount, 
	}

func getCurrentFrame() -> CarFrame:
	return CarFrame.new(
		global_position,
		global_rotation,
		getSpeed(),
		accelerationInput < 0,
		driftInput > 0,
		state.isAirborne(),
		state.impactTimer,
	)

func setGhostMode(ghostMode: bool):
	if ghostMode:
		%CarModel.setGhostMode(frameColor)
		for tire in tires:
			tire.visualRotationNode.get_child(0).setGhostMode(frameColor)
		%HeadLight.visible = false
		# %ReflectionProbe.update_mode = ReflectionProbe.UPDATE_ONCE

# [node name="ReflectionProbe" type="ReflectionProbe" parent="."]
# unique_name_in_owner = true
# transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 14, 0)
# update_mode = 1
# size = Vector3(64, 32, 64)
# origin_offset = Vector3(0, -11, 0)
# ambient_mode = 0

func setLabelVisibility(visible: bool):
	%PlayernameLabel.visible = visible

func set2DAudio():
	%CarEngineSound.set2DAudio()
	%CarSoundEffects.set2DAudio()
# DEBUG FUNCTIONS

func debugSkiddingRatio():
	var text = "Sliding Factor: "
	text += str(slidingFactor)
	return text

