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
	calculate_suspension(delta)
	calculate_steering(delta)
	calculate_engine(delta)
	
	if debugDraw != null:
		debugDraw.queue_redraw()
	else:
		print("debugDraw is null")

func calculate_suspension(delta):
	for index in 4:
		var force = 0
		var tireRayCast = raycasts[index]
		var tire = tires[index]
		if tireRayCast.is_colliding():
			var raycastDistance = (tireRayCast.global_transform.origin.distance_to(tireRayCast.get_collision_point()))
		
			# var springDirection = (tireRayCast.global_transform.origin - tireRayCast.get_collision_point()).normalized()
			var springDirection = tireRayCast.global_transform.basis.y
			var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin) * delta

			debugDraw.actualOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.actualVectors[index] = tireRayCast.get_collision_point() - tireRayCast.global_transform.origin
			
			var offset = SPRING_REST_DISTANCE - raycastDistance
			var velocity = springDirection.dot(tireVelocity)
			force = (offset * SPRING_STRENGTH) - (velocity * DAMPING)
			

			debugDraw.springOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.springVectors[index] = springDirection * force

			apply_force(springDirection * force, tireRayCast.global_transform.origin - global_transform.origin)
			
			if raycastDistance <= SPRING_REST_DISTANCE:
				var tireFinalPosition = tire.original_position + Vector3.UP * (SPRING_REST_DISTANCE - raycastDistance)
				tire.position = tireFinalPosition
			else:
				tire.position = tire.original_position

		else:
			debugDraw.springOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.springVectors[index] = Vector3.UP
			tire.position = tire.original_position
		index += 1

func calculate_steering(delta):
	for index in 4:
		var force = 0
		var tireRayCast = raycasts[index]
		var tire = tires[index]
		if tireRayCast.is_colliding():
			var steeringDirection = tireRayCast.global_transform.basis.x

			var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin)

			var steeringVelocity = steeringDirection.dot(tireVelocity)

			var desiredVelocityChange = -steeringVelocity * TIRE_GRIP

			var desiredAcceleration = desiredVelocityChange / delta

			force = steeringDirection  * desiredAcceleration * TIRE_MASS

			apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

			debugDraw.steeringOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.steeringVectors[index] = force
		else:
			debugDraw.steeringOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.steeringVectors[index] = Vector3.RIGHT

func calculate_engine(delta):
	for index in 4:
		var force = 0
		var tireRayCast = raycasts[index]
		var tire = tires[index]
		if tireRayCast.is_colliding():
			var accelerationDirection = tireRayCast.global_transform.basis.z

			force = accelerationDirection * accelerationInput * ACCELERATION			

			apply_force(force, tireRayCast.global_transform.origin - global_transform.origin)

			debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.accelerationVectors[index] = force
		else:
			debugDraw.accelerationOrigins[index] = tireRayCast.global_transform.origin
			debugDraw.accelerationVectors[index] = Vector3.FORWARD

func respawn():
	global_transform.basis = initialPosition
