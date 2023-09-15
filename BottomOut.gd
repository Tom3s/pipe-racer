extends RayCast3D

class_name CustomSeparationRay

var car: CarController = null
# Called when the node enters the scene tree for the first time.
func _ready():
	car = get_parent().get_parent()
	set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !car.paused && is_colliding():
		
		# var contactPoint = get_collision_point()
		var raycastDistance = (get_collision_point() - global_position).length()
		
		var tireVelocitySuspension = car.get_point_velocity(global_position)
		
		car.applyBottomedOutSuspension(raycastDistance, global_transform.basis.y, tireVelocitySuspension, global_position, delta)

