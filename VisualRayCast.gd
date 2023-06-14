extends RayCast3D

var tire = null
var smokeEmitter = null
var car = null
# Called when the node enters the scene tree for the first time.
func _ready():
	tire = get_child(0)
	smokeEmitter = get_child(1)
	smokeEmitter.emitting = false
	car = get_parent().get_parent()
	set_physics_process(true)

@export_range(0.1, 0.375, 0.001)
var VISUAL_TIRE_RADIUS = 0.355

func _physics_process(delta):
	if is_colliding():
		var rayCastDistance = global_position.distance_to(get_collision_point())
		tire.position = Vector3.DOWN * rayCastDistance + Vector3.UP * VISUAL_TIRE_RADIUS
		smokeEmitter.emitting = car.driftInput > 0.1 && car.linear_velocity.length() > 5
	else:
		var rayCastLength = target_position.length()
		tire.position = Vector3.DOWN * rayCastLength + Vector3.UP * VISUAL_TIRE_RADIUS
		smokeEmitter.emitting = false
