extends RayCast3D

var targetRotation: float = 0.0

var car: CarController = null

var tireModel = null

@export
var steeringSpeed: float = 0.05

@export
var tireMass: float = 20.0

@export
var tireIndex: int = 0

func _ready():
	car = get_parent().get_parent()
	tireModel = get_child(0)
	set_physics_process(true)

func _physics_process(delta):
	rotation.y = lerp(rotation.y, targetRotation, steeringSpeed)
	
	if is_colliding():
		car.groundedTires[tireIndex] = true
		
		var contactPoint = get_collision_point()
		var raycastDistance = (get_collision_point() - global_position).length()
		
		tireModel.position.y = -raycastDistance + 0.375
		
		var tireVelocitySuspension = car.get_point_velocity(global_position)
		
		car.applySuspension(raycastDistance, global_transform.basis.y, tireVelocitySuspension, global_position, delta)
		
		var tireVelocityActual = car.get_point_velocity(contactPoint)
		
		car.applyFriction(global_transform.basis.x, tireVelocityActual, tireMass, contactPoint)
	
		car.applyAcceleration(global_transform.basis.z, tireVelocityActual, contactPoint)
	else:
		car.groundedTires[tireIndex] = false		
		tireModel.position.y = target_position.y + 0.375
	
