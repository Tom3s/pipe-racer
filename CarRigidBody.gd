extends RigidBody3D

class_name CarRigidBody

@onready
var debugDraw: DebugDraw3D

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

var initialPosition: Vector3

var should_respawn: bool = false

const TIRE_RADIUS = 0.375

@export
var playerIndex: int = 1:
	set(newIndex):
		playerIndex = on_input_player_changed(newIndex)
	get:
		return playerIndex
	

const LOWER_SPEED_LIMIT = 0.008

# Called when the node enters the scene tree for the first time.
func _ready():
	raycasts.push_back(%BackLeftRayCast)
	raycasts.push_back(%BackRightRayCast)
	raycasts.push_back(%FrontLeftRayCast)
	raycasts.push_back(%FrontRightRayCast)

	tires.push_back(%BackLeftTire)
	tires.push_back(%BackRightTire)
	tires.push_back(%FrontLeftTire)
	tires.push_back(%FrontRightTire)

	debugDraw = get_parent().get_parent().get_parent().get_node("CanvasLayer").get_node("DebugDraw3D")

	initialPosition = global_transform.origin

	set_physics_process(true)

func get_point_velocity (point :Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_transform.origin)

func _physics_process(delta):
	calculate_forces(delta)
	
	if debugDraw != null:
		debugDraw.queue_redraw()
	else:
		print("debugDraw is null")
	
	if should_respawn:
		global_transform.origin = initialPosition
		linear_velocity = Vector3.UP * 0.1
		angular_velocity = Vector3.ZERO
		rotation = Vector3.ZERO
		should_respawn = false
		print("global_position: ", global_position)
		print("initialPosition: ", initialPosition)
		print("respawned")
	
	if linear_velocity.length() < LOWER_SPEED_LIMIT:
		linear_velocity = Vector3.ZERO
	
	print("steering factor: ", get_steering_factor())

func calculate_forces(delta) -> void:
	for index in 4:
		var tireRayCast = raycasts[index]
		var tire = tires[index]
		if tireRayCast.is_colliding():
			calculate_suspension(delta, tireRayCast, tire, index)
			calculate_steering(delta, tireRayCast, tire, index)
			calculate_engine(delta, tireRayCast, tire, index)
		else:
			calculate_air_pitch(delta)
			calculate_air_steering(delta)
			debugDraw.springOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.springVectors[index] = Vector3.UP
			tire.position = tire.original_position

			debugDraw.steeringOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.steeringVectors[index] = Vector3.RIGHT

			debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.accelerationVectors[index] = Vector3.FORWARD

			tire.rotate_x(accelerationInput / TIRE_RADIUS)
			
		if index in [2, 3]:
			tire.global_transform.origin += global_transform.basis.z * -0.65

func calculate_air_steering(delta):
	var yaw = steeringInput * AIR_STEERING
	# rotate_y(yaw * delta)
	apply_torque(global_transform.basis.y * yaw * delta)

func calculate_air_pitch(delta):
	var pitch = - accelerationInput * AIR_PITCH_CONTROL
	apply_torque(global_transform.basis.x * pitch * delta)
	

func calculate_suspension(delta, tireRayCast, tire, index):
		var raycastDistance = (tireRayCast.global_transform.origin.distance_to(tireRayCast.get_collision_point()))
	
		# var springDirection = (tireRayCast.global_transform.origin - tireRayCast.get_collision_point()).normalized()
		var springDirection = tireRayCast.global_transform.basis.y
		var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin) * delta

		debugDraw.actualOrigins[index] = tireRayCast.global_transform.origin
		debugDraw.actualVectors[index] = tireRayCast.get_collision_point() - tireRayCast.global_transform.origin
		
		var offset = SPRING_REST_DISTANCE - raycastDistance
		var velocity = springDirection.dot(tireVelocity)
		var force = (offset * SPRING_STRENGTH) - (velocity * DAMPING)
		

		debugDraw.springOrigins[index] = tireRayCast.global_transform.origin
		debugDraw.springVectors[index] = springDirection * force

		apply_force(springDirection * force, tireRayCast.global_transform.origin - global_transform.origin)
		
		var velocityDirection = tireRayCast.global_transform.basis.z

		var tireDistanceTravelled = tireVelocity.dot(velocityDirection)

		tire.rotate_x(tireDistanceTravelled / TIRE_RADIUS)
		
		if raycastDistance <= SPRING_REST_DISTANCE:
			var tireFinalPosition = tire.original_position + Vector3.DOWN * (raycastDistance - 0.28)
			tire.position = tireFinalPosition
		else:
			tire.position = tire.original_position



@export_range(0, 1, 0.05)
var MAX_FRICTION = 0.95
@export_range(0, 1, 0.1)
var SLIDE_FRICTION = 0.2
@export_range(0.05, 1, 0.05)
var MIN_FRICTION = 0.1
@export_range(0, 1, 0.1)
var SLIDE_TRESHOLD = 0.6

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
	return TIRE_GRIP

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

	

	debugDraw.steeringOrigins[index] = tireRayCast.global_transform.origin
	debugDraw.steeringVectors[index] = force
			
@export
var PASSIVE_BRAKING: int = 300

func calculate_engine(delta, tireRayCast, tire, index):
	var accelerationDirection = tireRayCast.global_transform.basis.z

	if accelerationInput == 0:
		var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin)
		var tireAxisVelocity = accelerationDirection.dot(tireVelocity)

		var desiredVelocityChange = - tireAxisVelocity * PASSIVE_BRAKING

		var desiredAcceleration = desiredVelocityChange * delta

		var force = accelerationDirection  * desiredAcceleration * TIRE_MASS

		apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

		debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
		debugDraw.accelerationVectors[index] = force

		return

	var force = accelerationDirection * accelerationInput * ACCELERATION			

	apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

	debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
	debugDraw.accelerationVectors[index] = force
	

func respawn():
	should_respawn = true

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

	return f.call(linear_velocity.length()) * STEERING
