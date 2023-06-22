extends RigidBody3D

class_name CarController


var shouldRespawn: bool = false

@export
var acceleration: float = 10

@export
var respawnPosition = Vector3(0, 10, 0)

@export
var respawnRotation = Vector3(0, PI/2, 0)

@export
var maxSteerAngle: float = PI/4

@export_range(0, 1, 0.001)
var tireGripFactor: float = 0.8

var steerInput: float = 0
var accelerationInput: float = 0
var driftInput: float = 0

var debugTireContactPoints: Dictionary = {}
var debugTireDirections: Dictionary = {}

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if shouldRespawn:
		global_position = respawnPosition
		angular_velocity = Vector3(0, 0, 0)
		linear_velocity = Vector3(0, 0, 0)
		rotation = respawnRotation
		shouldRespawn = false

func applyAcceleration(contactPoint: Vector3, direction: Vector3):
	var force = acceleration * mass * accelerationInput * direction
	DebugDraw.draw_arrow_ray(contactPoint, direction, 2, Color.DARK_GREEN, 0.02)
	apply_force(force, contactPoint - global_position)

func applyFriction(contactPoint: Vector3, tireVelocity: Vector3, direction: Vector3):
	DebugDraw.draw_arrow_ray(contactPoint, direction, 2, Color.DARK_RED, 0.02)
	
	var steeringVelocity = direction.dot(tireVelocity)
	
	var desiredVelocityChange = -steeringVelocity * tireGripFactor
	
	var desiredAcceleration = desiredVelocityChange * 120
	
	var force = direction * mass * desiredAcceleration
	
	DebugDraw.draw_arrow_ray(contactPoint, force, force.length() / (mass* 120), Color.DEEP_PINK, 0.1)
	
	apply_force(force, contactPoint - global_position)	
	
func respawn():
	shouldRespawn = true

func getDebugContactPointString():
	var debugString = ""
	for contactPoint in debugTireContactPoints:
		debugString += str(contactPoint) + ": " + str(debugTireContactPoints[contactPoint]) + "\n"
	return debugString

func getDebugTireDirectionsString():
	var debugString = ""
	for direction in debugTireDirections:
		debugString += str(direction) + ": " + str(debugTireDirections[direction]) + "\n"
	return debugString

func get_point_velocity (point :Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_transform.origin)
