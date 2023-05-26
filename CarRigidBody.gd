extends RigidBody3D

class_name CarRigidBody

@onready
var debugDraw: DebugDraw3D

var raycasts: Array = []
var tires: Array = []

@export
var SPRING_REST_DISTANCE: float = 0.375
@export
var SPRING_STRENGTH: float = 50
@export
var DAMPING: float = 7.5

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
	pass # Replace with function body.

func get_point_velocity (point :Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_transform.origin)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	calculate_suspension(delta)
	
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
			if index == 0:
				print("Raycast Distance: " + str(raycastDistance))
			var springDirection = (tireRayCast.global_transform.origin - tireRayCast.get_collision_point()).normalized()
			var tireVelocity = get_point_velocity(tireRayCast.global_transform.origin) * delta

			debugDraw.actualOrigin[index] = tireRayCast.global_transform.origin
			debugDraw.actualVector[index] = tireRayCast.get_collision_point() - tireRayCast.global_transform.origin
			
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
			debugDraw.springVectors[index] = Vector3(0,0,0)
		index += 1
