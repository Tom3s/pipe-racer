extends RayCast3D

var tire = null
# Called when the node enters the scene tree for the first time.
func _ready():
	tire = get_child(0)
	set_physics_process(true)

@export_range(0.1, 0.375, 0.001)
var VISUAL_TIRE_RADIUS = 0.355

func _physics_process(delta):
	if is_colliding():
		var rayCastDistance = global_position.distance_to(get_collision_point())
		tire.position = Vector3.DOWN * rayCastDistance + Vector3.UP * VISUAL_TIRE_RADIUS
	else:
		var rayCastLength = target_position.length()
		tire.position = Vector3.DOWN * rayCastLength + Vector3.UP * VISUAL_TIRE_RADIUS
