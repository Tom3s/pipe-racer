extends RayCast3D

var tire = null
# Called when the node enters the scene tree for the first time.
func _ready():
	tire = get_child(0)
	set_physics_process(true)

func _physics_process(delta):
	if is_colliding():
		var rayCastDistance = global_position.distance_to(get_collision_point())
		tire.position = Vector3.DOWN * rayCastDistance + Vector3.UP * 0.375
	else:
		var rayCastLength = target_position.length()
		tire.position = Vector3.DOWN * rayCastLength + Vector3.UP * 0.375
