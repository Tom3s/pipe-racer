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

# input vars
var accelerationInput: float = 0.0
var steeringInput: float = 0.0
var driftInput: float = 0.0

var groundedTires: Array = [false, false, false, false]

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	
	applyDownforce()
	
	if shouldRespawn:
		global_position = respawnPosition
		rotation = respawnRotation
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		shouldRespawn = false

func applyDownforce():
	var downforceFactor = remap(getForwardSpeed(), downforceMinimunSpeed, downforceMaximumSpeed, 0, 1)
	downforceFactor = clampf(downforceFactor, 0.0, 1.0)
	
	var groundedTireCount: float = 0.0
	for grounded in groundedTires:
		if grounded:
			groundedTireCount += 1
	
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

#	DebugDraw.draw_arrow_ray(suspensionPoint, force, force.length(), Color.DARK_CYAN, 0.02)

	apply_force(force, forcePosition)

func applyBottomedOutSuspension(raycastDistance: float, springDirection: Vector3, tireVelocity: Vector3, suspensionPoint: Vector3, delta: float):
	var offset = (springBottomOut) - (raycastDistance)
	var velocity = springDirection.dot(tireVelocity)
	var forceMagnitude = (offset * springConstant * 15 * mass) - (velocity * springDamping * 1.5)
	var force = forceMagnitude * springDirection #* mass

	apply_force(force, suspensionPoint - global_position)
	
func calculate_tire_grip():
	return tireGrip * remap(driftInput, 0, 1, 1, driftFactor)

func applyFriction(steeringDirection: Vector3, tireVelocity: Vector3, tireMass: float, contactPoint: Vector3):
	var steeringVelocity = steeringDirection.dot(tireVelocity)
	var tireGripFactor = calculate_tire_grip()
	
	var desiredVelocityChange = -steeringVelocity * tireGripFactor

	var desiredAcceleration = desiredVelocityChange * 120 #delta

	var force = steeringDirection * desiredAcceleration * tireMass
	
	DebugDraw.draw_arrow_ray(contactPoint, force, force.length(), Color.DARK_MAGENTA, 0.02)
	
	apply_force(force, contactPoint - global_position)

func applyAcceleration(accelerationDirection: Vector3, tireVelocity: Vector3, contactPoint: Vector3):
	if accelerationInput == 0:
		var tireAxisVelocity = accelerationDirection.dot(tireVelocity)
		var desiredVelocityChange = - tireAxisVelocity * passiveBraking

		var desiredAcceleration = desiredVelocityChange

		var force = accelerationDirection * desiredAcceleration #* mass
		
		DebugDraw.draw_arrow_ray(contactPoint, force, force.length(), Color.DARK_GREEN, 0.02)
		
		apply_force(force, contactPoint - global_position)
		return

	var force = accelerationDirection * accelerationInput * acceleration * mass

	if force.dot(linear_velocity) < 0:
		force *= brakingMultiplier
	
	DebugDraw.draw_arrow_ray(contactPoint, force, force.length(), Color.DARK_GREEN, 0.02)
	
	
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

func respawn():
	shouldRespawn = true
