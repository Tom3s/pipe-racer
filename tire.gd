extends RayCast3D

var targetRotation: float = 0.0

var car: CarController = null

var tireModel = null
var smokeEmitter: GPUParticles3D  = null
var dirtEmitter: GPUParticles3D = null

@export
var steeringSpeed: float = 0.05

@export
var tireMass: float = 20.0

@export
var tireIndex: int = 0

@export
var visualRotation: float = 2.0

func _ready():
	car = get_parent().get_parent()
	tireModel = get_child(0)
	smokeEmitter = get_child(1)
	smokeEmitter.emitting = false
	smokeEmitter.one_shot = false
	dirtEmitter = get_child(2)
	dirtEmitter.emitting = false
	dirtEmitter.one_shot = false
	set_physics_process(true)


var frictionMultiplier: float = 1.0
var accelerationMultiplier: float = 0.0
var collider: Node3D = null
var useSmokeParticles: bool = true
func _physics_process(delta):
	if !car.paused:
		if GlobalProperties.PRECISE_INPUT:
			rotation.y = targetRotation
		else:
			rotation.y = lerp(rotation.y, targetRotation, steeringSpeed)
	#	tireModel.rotation = tireModel.rotation * Vector3(1, 0, 1) + Vector3(0, rotation.y, 0)
		
		if is_colliding():
			car.state.groundedTires[tireIndex] = 1
			
			var contactPoint = get_collision_point()
			var raycastDistance = (get_collision_point() - global_position).length()
			
			tireModel.position.y = -raycastDistance + 0.375
			
			var tireVelocitySuspension = car.get_point_velocity(global_position)
			
			car.applySuspension(raycastDistance, global_transform.basis.y, tireVelocitySuspension, global_position, delta)
			
			var tireVelocityActual = car.get_point_velocity(contactPoint)
			
			# print(get_collider())
			collider = get_collider().get_parent()
			if collider.has_method("getFriction"):
				frictionMultiplier = collider.getFriction()
				accelerationMultiplier = collider.getAccelerationMultiplier()
				useSmokeParticles = collider.getSmokeParticles()
			else:
				frictionMultiplier = 1.0
				accelerationMultiplier = 1.0
				useSmokeParticles = true

			car.applyFriction(global_transform.basis.x, tireVelocityActual, tireMass, contactPoint, frictionMultiplier)
		
			car.applyAcceleration(global_transform.basis.z, tireVelocityActual, contactPoint, accelerationMultiplier)
			
			var tireDistanceTravelled = (tireVelocitySuspension * delta).dot(global_transform.basis.z)
			
			tireModel.rotate_x(tireDistanceTravelled / 0.375)
			
			smokeEmitter.emitting = car.slidingFactor > 0.1 && car.getSpeed() > 15 && useSmokeParticles
			dirtEmitter.emitting = car.getSpeed() > 15 && !useSmokeParticles
			# smokeEmitter.emitting = car.slidingFactor > 0.1
		else:
			car.state.groundedTires[tireIndex] = 0		
			tireModel.position.y = target_position.y + 0.375
			smokeEmitter.emitting = false
			dirtEmitter.emitting = false
	
