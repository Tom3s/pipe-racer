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

var accelerationInput: float = 0

var initialPosition: Vector3

var should_respawn: bool = false

const TIRE_RADIUS = 0.375

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
	print("position: ", global_transform.origin)

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

func calculate_forces(delta) -> void:
	for index in 4:
		var tireRayCast = raycasts[index]
		var tire = tires[index]
		if tireRayCast.is_colliding():
			calculate_suspension(delta, tireRayCast, tire, index)
			calculate_steering(delta, tireRayCast, tire, index)
			calculate_engine(delta, tireRayCast, tire, index)
		else:
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
			var tireFinalPosition = tire.original_position + Vector3.UP * (SPRING_REST_DISTANCE - raycastDistance)
			tire.position = tireFinalPosition
		else:
			tire.position = tire.original_position


const MAX_FRICTION = 0.8
const MIN_FRICTION = 0.2
const SLIDE_TRESHOLD = 0.5
const SLIDE_FRICTION = 0.3

func calculate_tire_grip(tireVelocity, steeringDirection):
	var x = abs(tireVelocity.normalized().dot(steeringDirection))
	if x < SLIDE_TRESHOLD:
		return remap(x, 0, 1, MAX_FRICTION, SLIDE_FRICTION) 
	else:
		return remap(x, 0, 1, SLIDE_FRICTION, MIN_FRICTION)

func calculate_steering(delta, tireRayCast, tire, index):
	var steeringDirection = tireRayCast.global_transform.basis.x

	var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin)

	var steeringVelocity = steeringDirection.dot(tireVelocity)
	
	# var desiredVelocityChange = -steeringVelocity * (1 - calculate_tire_grip(tireVelocity, steeringDirection))# TIRE_GRIP
	var desiredVelocityChange = -steeringVelocity * calculate_tire_grip(tireVelocity, steeringDirection)# TIRE_GRIP

	var desiredAcceleration = desiredVelocityChange / delta

	var force = steeringDirection  * desiredAcceleration * TIRE_MASS

	apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

	

	debugDraw.steeringOrigins[index] = tireRayCast.global_transform.origin
	debugDraw.steeringVectors[index] = force
			

func calculate_engine(delta, tireRayCast, tire, index):
	var accelerationDirection = tireRayCast.global_transform.basis.z

	if accelerationInput == 0:
		var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin)
		var tireAxisVelocity = accelerationDirection.dot(tireVelocity)

		var desiredVelocityChange = -tireAxisVelocity * 0.005

		var desiredAcceleration = desiredVelocityChange / delta

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
	

