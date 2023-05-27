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

var initialPosition: Basis

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

	initialPosition = global_transform.basis

func get_point_velocity (point :Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_transform.origin)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	calculate_forces(delta)
	
	if debugDraw != null:
		debugDraw.queue_redraw()
	else:
		print("debugDraw is null")

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

func calculate_steering(delta, tireRayCast, tire, index):
	var steeringDirection = tireRayCast.global_transform.basis.x

	var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin)

	var steeringVelocity = steeringDirection.dot(tireVelocity)

	var desiredVelocityChange = -steeringVelocity * TIRE_GRIP

	var desiredAcceleration = desiredVelocityChange / delta

	var force = steeringDirection  * desiredAcceleration * TIRE_MASS

	apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

	debugDraw.steeringOrigins[index] = tireRayCast.global_transform.origin
	debugDraw.steeringVectors[index] = force
			

func calculate_engine(delta, tireRayCast, tire, index):
	var accelerationDirection = tireRayCast.global_transform.basis.z

	var force = accelerationDirection * accelerationInput * ACCELERATION			

	apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

	debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
	debugDraw.accelerationVectors[index] = force
	

func respawn():
	# global_transform.basis = initialPosition
	apply_impulse(Vector3.UP * 5, Vector3(1, 0, 0))
