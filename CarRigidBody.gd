extends RigidBody3D

class_name CarRigidBody

# @onready
# var debugDraw: DebugDraw3D


var raycasts: Array = []
var tires: Array = []

@export
var SPRING_REST_DISTANCE: float = 0.375
@export
var SPRING_STRENGTH: float = 55
@export
var SPRING_MAX_COMPRESSION: float = 0.10
@export
var DAMPING: float = 150
@export
var TIRE_GRIP: float = 1
@export
var TIRE_MASS: float = 1
@export
var ACCELERATION: float = 5
@export
var STEERING: float = 0.3

@export
var AIR_STEERING: float = 1000
@export
var AIR_PITCH_CONTROL: float = 1000

var accelerationInput: float = 0
var steeringInput: float = 0

var respawnPosition: Vector3
var respawnRotation: Vector3

var spawnPosition: Vector3
var spawnRotation: Vector3

var should_respawn: bool = false

const TIRE_RADIUS = 0.375

@export
var playerIndex: int = 1:
	set(newIndex):
		playerIndex = on_input_player_changed(newIndex)
	get:
		return playerIndex

@export
var frameColor: Color = Color.PINK:
	set(newColor):
		frameColor = onFrameColorChanged(newColor)
	get:
		return frameColor

func onFrameColorChanged(newColor: Color) -> Color:
	var rollcage: MeshInstance3D = get_node("%CarModel/%Rollcage")
	# rollcage.set_surface_override_material(0, rollcage.get_surface_override_material(0).duplicate())
	rollcage.get_surface_override_material(0).set("albedo_color", newColor)
	return newColor

const LOWER_SPEED_LIMIT = 0.008

@export
var SOUND_SPEED_LIMIT: float = 0.1


const FRICTION = 0.34

# func _init(initialPlayerIndex: int = 1, initialColor: Color = Color(1, 1, 1, 1)):
# 	playerIndex = initialPlayerIndex
# 	var rollcage = get_node("%CarModel/%Rollcage")
# 	rollcage.set("surface_material_override/albedo_color", initialColor)

@onready
var synchronizer = %MultiplayerSynchronizer

var playerName: String = Playerstats.PLAYER_NAME

var pauseLinearVelocity: Vector3
var pauseAngularVelocity: Vector3

var paused: bool = false

signal finishedRacing()


func _ready():
	synchronizer.set_multiplayer_authority(name.to_int())

	raycasts.push_back(%BackLeftRayCast)
	raycasts.push_back(%BackRightRayCast)
	raycasts.push_back(%FrontLeftRayCast)
	raycasts.push_back(%FrontRightRayCast)

	tires.push_back(%BackLeftTire)
	tires.push_back(%BackRightTire)
	tires.push_back(%FrontLeftTire)
	tires.push_back(%FrontRightTire)

	var rollcage: MeshInstance3D = get_node("%CarModel/%Rollcage")
	rollcage.set_surface_override_material(0, rollcage.get_surface_override_material(0).duplicate())

	var startLine: StartLine = get_parent().get_parent().get_node("%Start/%StartLine")

	startLine.body_entered.connect(onStartLine_bodyEntered)
	startLine.body_exited.connect(onStartLine_bodyExited)

	if respawnPosition == null:
		respawnPosition = global_transform.origin

	if playerIndex != 1 && playerName == Playerstats.PLAYER_NAME:
		playerName += "_" + str(playerIndex)

	set_physics_process(true)

	if synchronizer.is_multiplayer_authority():
		get_parent().get_node("%UniversalCanvas/Countdown").countdownFinished.connect(onCountdown_finished)

		var camera = FollowingCamera.new(self)

		var viewPortContainer = SubViewportContainer.new()
		viewPortContainer.stretch = true
		viewPortContainer.size_flags_horizontal = SubViewportContainer.SIZE_EXPAND_FILL
		viewPortContainer.size_flags_vertical = SubViewportContainer.SIZE_EXPAND_FILL
		var viewPort = SubViewport.new()
		viewPort.audio_listener_enable_3d = true
		viewPort.render_target_update_mode = SubViewport.UPDATE_ALWAYS

		var canvasLayer = CanvasLayer.new()
		canvasLayer.follow_viewport_enabled = true
		viewPort.add_child(canvasLayer)

		viewPortContainer.add_child(viewPort)
		viewPort.add_child(camera)

		get_parent().get_node("%VerticalSplitTop").add_child(viewPortContainer)
		get_parent().get_node("%VerticalSplitBottom").visible = false

	respawn()

func get_point_velocity (point :Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_transform.origin)

@export
var ENGINE_SOUND_PITCH_FACTOR: float = 3.0

@export
var gear1Speed = 1

@export
var gear6Speed = 150

func _physics_process(delta):
	calculate_forces(delta)

	# print("friction: ", physics_material_override.friction)
	
	# if debugDraw != null:
		# debugDraw.queue_redraw()
	# else:
		# print("debugDraw is null")
	
	if should_respawn:
		global_transform.origin = respawnPosition
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		global_rotation = respawnRotation + Vector3.UP * PI / 2
		should_respawn = false
	
	if getSpeed() < LOWER_SPEED_LIMIT:
		linear_velocity *= Vector3.UP
	
	if getSpeed() < SOUND_SPEED_LIMIT:
		# %CarEngineSound.tempo = 120
		# %CarEngineSound.targetPitchScale = 0.75
		%CarEngineSound.playingIdle = true
	else:
		# %CarEngineSound.tempo = remap(getSpeed(), 1, 75, 170, 170 * ENGINE_SOUND_PITCH_FACTOR)
		%CarEngineSound.targetPitchScale = max(0, remap(getSpeed(), SOUND_SPEED_LIMIT, gear6Speed, 1, 4))
		%CarEngineSound.playingIdle = false
	
	synchronizer.position = position
	synchronizer.rotation = rotation
	synchronizer.linear_velocity = linear_velocity
	synchronizer.angular_velocity = angular_velocity
	synchronizer.frameColor = frameColor
	synchronizer.timeTrialState = timeTrialState
	synchronizer.respawnPosition = respawnPosition
	synchronizer.driftInput = driftInput

	if timeTrialState == TimeTrialState.COUNTDOWN:
		recalculateSpawnPositions()
		linear_velocity *= Vector3.UP


func recalculateSpawnPositions():
	if (global_position * Vector3(1, 0, 1)).distance_to(respawnPosition * Vector3(1, 0, 1)) > SOUND_SPEED_LIMIT:
		respawn()

	var needsRespawn: bool = false
	var spawnPositions: Array = []

	var cars = get_parent().get_children()

	for car in cars:
		if car is CarRigidBody:
			spawnPositions.push_back(car.respawnPosition)

	for i in spawnPositions.size():
		for j in spawnPositions.size():
			if i != j and spawnPositions[i].distance_to(spawnPositions[j]) < 1:
				needsRespawn = true
				print("Respawn recalculation needed")
				break
	
	if !needsRespawn:
		return

	cars.sort_custom(func(a, b): return a.name.to_int() < b.name.to_int())
	
	# for index in get_parent().get_child_count():
	# 	get_parent().get_child(index).respawnPosition = cars[0].global_position + Vector3(0, 0, index * 10)
	
	for index in cars.size():
		cars[index].respawnPosition = cars[0].respawnPosition + Vector3(0, 0, index * 10)	
		cars[index].spawnPosition = cars[index].respawnPosition

	# for index in get_parent().get_child_count():
	# 	get_parent().get_child(index).respawn()




# var physicsMaterial: PhysicsMaterial = null

func calculate_forces(delta) -> void:
	# physics_material_override.friction = FRICTION
	var springOvercompressionCorrection = Vector3.ZERO
	for index in 4:
		var tireRayCast = raycasts[index]
		var tire = tires[index]
		if tireRayCast.is_colliding():
			# physics_material_override.friction =  0
			var overCompressionForce = calculate_suspension(delta, tireRayCast, tire, index)
			springOvercompressionCorrection = springOvercompressionCorrection if springOvercompressionCorrection.length() > overCompressionForce.length() else overCompressionForce
			calculate_steering(delta, tireRayCast, tire, index)
			calculate_engine(delta, tireRayCast, tire, index)
		else:
			calculate_air_pitch(delta)
			calculate_air_steering(delta)
			# debugDraw.springOrigins[index] = tireRayCast.global_transform.origin
			# debugDraw.springVectors[index] = Vector3.UP
			# tire.position = tire.original_position

			# debugDraw.steeringOrigins[index] = tireRayCast.global_transform.origin
			# debugDraw.steeringVectors[index] = Vector3.RIGHT

			# debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
			# debugDraw.accelerationVectors[index] = Vector3.FORWARD

			tire.rotate_x(accelerationInput / TIRE_RADIUS)
	# apply_central_force(springOvercompressionCorrection)
	global_position += springOvercompressionCorrection
		# if index in [2, 3]:
		# 	tire.global_transform.origin += global_transform.basis.z * -0.65

func calculate_air_steering(delta):
	var yaw = steeringInput * AIR_STEERING
	# rotate_y(yaw * delta)
	apply_torque(global_transform.basis.y * yaw * delta)

func calculate_air_pitch(delta):
	var pitch = - accelerationInput * AIR_PITCH_CONTROL
	apply_torque(global_transform.basis.x * pitch * delta)
	

func calculate_suspension(delta, tireRayCast, tire, index):
		var raycastDistance = (tireRayCast.global_transform.origin.distance_to(tireRayCast.get_collision_point()))
		var springDirection = tireRayCast.global_transform.basis.y

		var overcompressedSpringForce = Vector3.ZERO
		# TODO uncomment this for less ground clipping
		if raycastDistance <= SPRING_MAX_COMPRESSION:
		# 	global_position += springDirection * (SPRING_MAX_COMPRESSION - raycastDistance)
			# raycastDistance = (tireRayCast.global_transform.origin.distance_to(tireRayCast.get_collision_point()))
			overcompressedSpringForce = springDirection * ( (SPRING_MAX_COMPRESSION - raycastDistance)) #linear_velocity.dot(springDirection) +
			# TODO this cancels momentum as well
			linear_velocity -= linear_velocity.dot(springDirection) * springDirection


		# var springDirection = (tireRayCast.global_transform.origin - tireRayCast.get_collision_point()).normalized()
		var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin) * delta

		# debugDraw.actualOrigins[index] = tireRayCast.global_transform.origin
		# debugDraw.actualVectors[index] = tireRayCast.get_collision_point() - tireRayCast.global_transform.origin
		
		var offset = SPRING_REST_DISTANCE - raycastDistance
		var velocity = springDirection.dot(tireVelocity)
		var force = (offset * SPRING_STRENGTH) - (velocity * DAMPING)

		
		

		# debugDraw.springOrigins[index] = tireRayCast.global_transform.origin
		# debugDraw.springVectors[index] = springDirection * force

		apply_force(springDirection * force, tireRayCast.global_transform.origin - global_transform.origin)
		
		var velocityDirection = tireRayCast.global_transform.basis.z

		var tireDistanceTravelled = tireVelocity.dot(velocityDirection)

		tire.rotate_x(tireDistanceTravelled / TIRE_RADIUS)
		
		# var tireFinalPosition = tire.original_position + Vector3.DOWN * (raycastDistance - 0.28)
		# tire.position = tireFinalPosition
		# apply_force(overcompressedSpringForce, tireRayCast.global_transform.origin - global_transform.origin)
		return overcompressedSpringForce



@export_range(0, 1, 0.05)
var MAX_FRICTION = 0.95
@export_range(0, 1, 0.1)
var SLIDE_FRICTION = 0.2
@export_range(0.05, 1, 0.05)
var MIN_FRICTION = 0.1
@export_range(0, 1, 0.1)
var SLIDE_TRESHOLD = 0.6

@export_range(0.1, 1, 0.1)
var DRIFT_FACTOR = 0.5

var driftInput: float = 0

func calculate_tire_grip(tireVelocity, steeringDirection):
	# var x = tireVelocity.dot(steeringDirection)
	# # x = clamp(abs(x), 0, 1)
	# return remap(x / tireVelocity.length(), 0, 1, MAX_FRICTION, MIN_FRICTION)
	# return max(MIN_FRICTION, remap(tireVelocity.length(), 0, 75, MAX_FRICTION, MIN_FRICTION))
	# var x = abs(tireVelocity.dot(steeringDirection)) / tireVelocity.length()
	# if x > SLIDE_TRESHOLD:
	# 	return remap(x, SLIDE_TRESHOLD, 1, SLIDE_FRICTION, MIN_FRICTION)
	# else:
	# 	return remap(x, 0, SLIDE_TRESHOLD, MAX_FRICTION, SLIDE_FRICTION)
	return TIRE_GRIP * remap(driftInput, 0, 1, 1, DRIFT_FACTOR)

func calculate_steering(delta, tireRayCast, tire, index):
	var steeringDirection = tireRayCast.global_transform.basis.x

	var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin)

	var steeringVelocity = steeringDirection.dot(tireVelocity)
	
	# var desiredVelocityChange = -steeringVelocity * (1 - calculate_tire_grip(tireVelocity, steeringDirection))# TIRE_GRIP
	var tireGripFactor = calculate_tire_grip(tireVelocity, steeringDirection)
	# print("tireGripFactor: ", tireGripFactor)
	var desiredVelocityChange = -steeringVelocity * tireGripFactor# TIRE_GRIP

	var desiredAcceleration = desiredVelocityChange / delta

	var force = steeringDirection * desiredAcceleration * TIRE_MASS

	apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

	

	# debugDraw.steeringOrigins[index] = tireRayCast.global_transform.origin
	# debugDraw.steeringVectors[index] = force
			
@export
var PASSIVE_BRAKING: int = 300
@export
var BRAKING_FORCE: int = 2

func calculate_engine(delta, tireRayCast, tire, index):
	var accelerationDirection = tireRayCast.global_transform.basis.z

	if accelerationInput == 0:
		var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin)
		var tireAxisVelocity = accelerationDirection.dot(tireVelocity)

		var desiredVelocityChange = - tireAxisVelocity * PASSIVE_BRAKING

		var desiredAcceleration = desiredVelocityChange * delta

		var force = accelerationDirection  * desiredAcceleration * TIRE_MASS

		apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

		# debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
		# debugDraw.accelerationVectors[index] = force

		return

	var force = accelerationDirection * accelerationInput * ACCELERATION			

	if force.dot(linear_velocity) < 0:
		force *= BRAKING_FORCE
	apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

	# debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
	# debugDraw.accelerationVectors[index] = force
	

func respawn():
	print("RespawnPos for ", name , ": ", respawnPosition)
	should_respawn = true
	# timeTrialState = TimeTrialState.WAITING

func on_input_player_changed(newIndex: int) -> int:
	%InputHandler.set_input_player(newIndex)
	return newIndex

func get_steering_factor() -> float:
	# return STEERING
	# start with 0.3
	# retain 90% of the value until speed 40
	# y = ((cos(x/80) + 1) ** 3) / 8
	# var f = func(x): return ((cos(x/80) + 1) ** 2) / 4
	# var g = func(x): return ((cos(1.0/5000*x**2))+1)/2
	var g = func(x): return (- x / 150) + 1
	var f = func(x): return max(g.call(x), 0.25)

	return f.call(getSpeed()) * STEERING

enum TimeTrialState {
	COUNTDOWN,
	WAITING,
	STARTING,
	ONGOING,
	FINISHED
}

var timeTrialState: TimeTrialState = TimeTrialState.COUNTDOWN
var startTime: int = 0

var currentCheckPoint: int = 0
var nrCheckpoints: int = 0

var nrLaps = 0
var currentLap = 0

var placement: int = 0

var timeTrialManager: TimeTrialManager = null

func onStartLine_bodyEntered(body: Node3D) -> void:
	if body == self:
		if timeTrialState == TimeTrialState.WAITING:
			timeTrialState = TimeTrialState.STARTING

		elif timeTrialState == TimeTrialState.ONGOING:
			if currentCheckPoint == nrCheckpoints:
				timeTrialState = TimeTrialState.STARTING
				currentCheckPoint = 0
				currentLap += 1

				timeTrialManager.finishedLap()

				if currentLap >= nrLaps:
					timeTrialState = TimeTrialState.FINISHED
					accelerationInput = 0
					steeringInput = 0
					driftInput = 0
					if synchronizer.is_multiplayer_authority() || get_tree().get_multiplayer().is_server():
						Leaderboard.addScoreTotalTime(timeTrialManager.getTotalTime(), playerName)
						Leaderboard.addScoreBestLap(timeTrialManager.getBestLap(), playerName)
					finishedRacing.emit()
			

var incorrectCheckPoint: bool = false

func onStartLine_bodyExited(body: Node3D) -> void:
	if body == self:
		if timeTrialState == TimeTrialState.STARTING:
			timeTrialState = TimeTrialState.ONGOING

func onCheckpoint_bodyEntered(body: Node3D, checkpoint: Node3D) -> void:
	if body == self:
		var cpIndex = int(checkpoint.name.replace("cp", ""))
		# print("Player ", playerIndex, " entered checkpoint ", cpIndex)

		# print("currentCheckPoint: ", currentCheckPoint)
		# print("cpIndex: ", cpIndex)
		# print("nrCheckpoints: ", nrCheckpoints)
	

		if cpIndex == currentCheckPoint + 1:
			placement = checkpoint.getPlacement(currentLap)
			currentCheckPoint = cpIndex
			respawnPosition = checkpoint.global_position
			respawnRotation = checkpoint.global_rotation.rotated(Vector3.UP, PI)
			incorrectCheckPoint = false

			print("Player ", name, " entered checkpoint ", cpIndex)
		else:
			incorrectCheckPoint = !cpIndex == currentCheckPoint

func onCountdown_finished(_timestamp) -> void:
	if timeTrialState == TimeTrialState.COUNTDOWN:
		timeTrialState = TimeTrialState.STARTING
		spawnPosition = respawnPosition
		spawnRotation = respawnRotation

func reset():
	timeTrialState = TimeTrialState.COUNTDOWN
	timeTrialManager.reset()
	respawnPosition = spawnPosition
	respawnRotation = spawnRotation
	respawn()

	currentCheckPoint = 0
	currentLap = 0

	timeTrialManager.reset()

func getSpeed() -> float:
	var velocityForward = global_transform.basis.z.dot(linear_velocity)
	var velocityRight = global_transform.basis.x.dot(linear_velocity)

	return Vector2(velocityForward, velocityRight).length()

			
		

			
			
		
