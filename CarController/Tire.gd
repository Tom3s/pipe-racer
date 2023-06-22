extends RigidBody3D

var car: CarController = null

# Called when the node enters the scene tree for the first time.
func _ready():
	car = get_parent().get_parent().get_parent()
	set_physics_process(true)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if state.get_contact_count() != 0:
#		var contactPoint = state.get_contact_local_position(0) - state.get_contact_collider_position(0)# + global_position
		var contactPoint = state.get_contact_local_position(0) + state.get_contact_collider_object(0).global_position
		car.debugTireContactPoints[name] = contactPoint - global_position
		car.applyAcceleration(contactPoint, global_transform.basis.z)
		
#		DebugDraw.draw_arrow_ray(contactPoint, global_transform.basis.z, 1, Color.DARK_GREEN)
		
#		var tireVelocity = state.get_velocity_at_local_position(contactPoint)
		var tireVelocity = car.get_point_velocity(contactPoint)

		var steeringDirection = -1 * global_transform.basis.y
#		var tireVelocity = state.get_velocity_at_local_position(contactPoint - global_position)

		car.applyFriction(contactPoint, tireVelocity, steeringDirection)
		
